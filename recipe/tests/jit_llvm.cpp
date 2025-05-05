#include <drjit/dynamic.h>
#include <drjit/jit.h>
#include <drjit/random.h>

int main() {
  using FloatC = drjit::LLVMArray<float>;
  using PCG32C = drjit::PCG32<FloatC>;
  using Vec3fC = drjit::Array<FloatC, 3>;
  using MaskC = drjit::mask_t<FloatC>;

  jit_init();

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
