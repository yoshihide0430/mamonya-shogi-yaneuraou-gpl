LOCAL_PATH := $(call my-dir)
YANEURAOU_ROOT := $(LOCAL_PATH)/../third_party/YaneuraOu

include $(CLEAR_VARS)

LOCAL_MODULE := yaneuraou

LOCAL_SRC_FILES := \
  ../third_party/YaneuraOu/source/main.cpp \
  ../third_party/YaneuraOu/source/types.cpp \
  ../third_party/YaneuraOu/source/bitboard.cpp \
  ../third_party/YaneuraOu/source/misc.cpp \
  ../third_party/YaneuraOu/source/movegen.cpp \
  ../third_party/YaneuraOu/source/position.cpp \
  ../third_party/YaneuraOu/source/usi.cpp \
  ../third_party/YaneuraOu/source/usioption.cpp \
  ../third_party/YaneuraOu/source/thread.cpp \
  ../third_party/YaneuraOu/source/tt.cpp \
  ../third_party/YaneuraOu/source/movepick.cpp \
  ../third_party/YaneuraOu/source/timeman.cpp \
  ../third_party/YaneuraOu/source/memory.cpp \
  ../third_party/YaneuraOu/source/engine.cpp \
  ../third_party/YaneuraOu/source/search.cpp \
  ../third_party/YaneuraOu/source/score.cpp \
  ../third_party/YaneuraOu/source/benchmark.cpp \
  ../third_party/YaneuraOu/source/tune.cpp \
  ../third_party/YaneuraOu/source/book/book.cpp \
  ../third_party/YaneuraOu/source/book/apery_book.cpp \
  ../third_party/YaneuraOu/source/book/policybook.cpp \
  ../third_party/YaneuraOu/source/extra/bitop.cpp \
  ../third_party/YaneuraOu/source/extra/long_effect.cpp \
  ../third_party/YaneuraOu/source/extra/sfen_packer.cpp \
  ../third_party/YaneuraOu/source/mate/mate.cpp \
  ../third_party/YaneuraOu/source/mate/mate1ply_without_effect.cpp \
  ../third_party/YaneuraOu/source/mate/mate1ply_with_effect.cpp \
  ../third_party/YaneuraOu/source/mate/mate_solver.cpp \
  ../third_party/YaneuraOu/source/eval/evaluate_bona_piece.cpp \
  ../third_party/YaneuraOu/source/eval/evaluate.cpp \
  ../third_party/YaneuraOu/source/eval/evaluate_io.cpp \
  ../third_party/YaneuraOu/source/eval/evaluate_mir_inv_tools.cpp \
  ../third_party/YaneuraOu/source/eval/material/evaluate_material.cpp \
  ../third_party/YaneuraOu/source/testcmd/unit_test.cpp \
  ../third_party/YaneuraOu/source/testcmd/mate_test_cmd.cpp \
  ../third_party/YaneuraOu/source/testcmd/normal_test_cmd.cpp \
  ../third_party/YaneuraOu/source/book/makebook.cpp \
  ../third_party/YaneuraOu/source/book/makebook2025.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/evaluate_nnue.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/nnue_test_command.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/k.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/p.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/a2.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_kp.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_ka1.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_ka_hm1.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_ka2.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_ka_hm2.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_kp_vm.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_relative_kp.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/half_kpe9.cpp \
  ../third_party/YaneuraOu/source/eval/nnue/features/pe9.cpp \
  ../third_party/YaneuraOu/source/engine/yaneuraou-engine/yaneuraou-search.cpp

LOCAL_C_INCLUDES := $(YANEURAOU_ROOT)/source

LOCAL_CPPFLAGS := \
  -std=c++17 \
  -fno-exceptions \
  -fno-rtti \
  -Ofast \
  -flto \
  -pthread \
  -fPIE \
  -DNDEBUG \
  -D_LINUX \
  -DUNICODE \
  -DNO_EXCEPTIONS \
  -DUSE_MAKEFILE \
  -DYANEURAOU_ENGINE_NNUE \
  -DUSE_PTHREADS \
  -DIS_64BIT \
  -DUSE_NEON=8 \
  -DUSE_NEON_DOTPROD \
  -march=armv8.2-a+dotprod \
  -DHASH_KEY_BITS=128 \
  -DTT_CLUSTER_SIZE=4 \
  -DTARGET_CPU=\"ARMV8_DOTPROD\" \
  -DENGINE_NAME_FROM_MAKEFILE=YaneuraOu_MamoShogi \
  -D__STDINT_MACROS \
  -D__STDC_LIMIT_MACROS \
  -Wno-unused-parameter \
  -Wno-unused-variable \
  -Wno-unused-function

LOCAL_LDFLAGS := -fPIE -pie -flto -pthread

include $(BUILD_EXECUTABLE)
