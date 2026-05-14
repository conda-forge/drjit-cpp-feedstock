#define DRJIT_INCLUDE_FLOAT16_FALLBACK 1

#include <drjit-core/half.h>

#include <cmath>
#include <iostream>

int main() {
    const drjit::half one = drjit::half::from_binary(0x3c00);
    const drjit::half three_halves(1.5f);

    const float sum = static_cast<float>(one) + static_cast<float>(three_halves);
    if (std::abs(sum - 2.5f) > 0.001f) {
        std::cerr << "unexpected half conversion result: " << sum << std::endl;
        return 1;
    }

    return 0;
}
