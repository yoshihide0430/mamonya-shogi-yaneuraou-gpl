#include "eval/nnue/layers/input_slice.h"
#include "eval/nnue/layers/affine_transform_sparse_input.h"
#include <sstream>
#include <iostream>
#include <memory>

using namespace YaneuraOu;
using namespace YaneuraOu::Eval::NNUE;
int main() {
    using Layer = Layers::AffineTransformSparseInput<Layers::InputSlice<512>, 32>;
    auto layer = std::make_unique<Layer>();
    alignas(64) TransformedFeatureType input[512];
    alignas(64) char buffer[Layer::kBufferSize];
    int failures = 0;
    for (int trial = 0; trial < 16; ++trial) {
        std::stringstream params(std::ios::in | std::ios::out | std::ios::binary);
        int32_t biases[32];
        int8_t weights[32][512];
        for (int j = 0; j < 32; ++j) {
            biases[j] = j * 31 - 256;
            params.write(reinterpret_cast<char*>(&biases[j]), sizeof(int32_t));
        }
        for (int j = 0; j < 32; ++j)
            for (int i = 0; i < 512; ++i) {
                weights[j][i] = int8_t((i * 17 + j * 11 + trial * 7) % 255 - 128);
                params.write(reinterpret_cast<char*>(&weights[j][i]), 1);
            }
        for (int i = 0; i < 512; ++i) input[i] = (i * 13 + trial * 19) % 128;
        if (layer->ReadParameters(params).is_not_ok()) return 2;
        const auto actual = layer->Propagate(input, buffer);
        for (int j = 0; j < 32; ++j) {
            int32_t expected = biases[j];
            for (int i = 0; i < 512; ++i) expected += int(input[i]) * int(weights[j][i]);
            if (actual[j] != expected) {
                if (failures < 4) std::cout << "trial=" << trial << " output=" << j << " expected=" << expected << " actual=" << actual[j] << '\n';
                ++failures;
            }
        }
    }
    std::cout << "mismatches=" << failures << "/512\n";
    return failures ? 1 : 0;
}
