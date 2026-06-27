#include <drjit/dynamic.h>
#include <drjit/jit.h>
#include <drjit/random.h>
#include <drjit-core/jit.h>
#include <iostream>

int main() {
  using FloatC = drjit::LLVMArray<float>;
  using PCG32C = drjit::PCG32<FloatC>;
  using Vec3fC = drjit::Array<FloatC, 3>;
  using MaskC = drjit::mask_t<FloatC>;

  jit_init();

  int llvm_major = -1, llvm_minor = -1, llvm_patch = -1;
  jit_llvm_version(&llvm_major, &llvm_minor, &llvm_patch);
  if (llvm_major < 0) {
    std::cerr << "Dr.Jit LLVM backend did not report a loaded LLVM version"
              << std::endl;
    return 1;
  }

#ifdef EXPECT_CONSUMER_LLVM_MAJOR
  if (llvm_major == EXPECT_CONSUMER_LLVM_MAJOR) {
    std::cerr << "Dr.Jit unexpectedly used consumer LLVM " << llvm_major
              << "." << llvm_minor << "." << llvm_patch << std::endl;
    return 1;
  }
#endif

  PCG32C rng(1'000'000);

  Vec3fC v(
      rng.next_float32() * 2.f - 1.f,
      rng.next_float32() * 2.f - 1.f,
      rng.next_float32() * 2.f - 1.f);

  MaskC inside = drjit::norm(v) < 1.f;

  std::cout << drjit::count(inside) / (float)inside.size() << std::endl;

  jit_sync_all_devices();

  return 0;
}
