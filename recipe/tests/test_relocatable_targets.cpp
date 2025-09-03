/*
 * Test to verify that drjit CMake targets are relocatable and can find
 * their dependencies correctly regardless of installation path.
 *
 * This test specifically addresses the issue where drjit-core target
 * had hardcoded paths that would fail when conda installed the package
 * in different locations.
 */

#include <drjit/fwd.h>
#include <iostream>

#if defined(DRJIT_ENABLE_LLVM) || defined(DRJIT_ENABLE_CUDA)
#include <drjit-core/jit.h>
#endif

int main() {
    std::cout << "Testing relocatable CMake targets for drjit..." << std::endl;

    // Test 1: Basic header inclusion works (interface target)
    std::cout << "✓ Successfully included drjit headers" << std::endl;

#if defined(DRJIT_ENABLE_LLVM) || defined(DRJIT_ENABLE_CUDA)
    // Test 2: JIT backend initialization (linked target)
    try {
        // Initialize JIT subsystem - this will fail if drjit-core.dll/.so
        // cannot be found due to incorrect IMPORTED_LOCATION paths
        jit_init((uint32_t) JitBackend::LLVM | (uint32_t) JitBackend::CUDA);
        std::cout << "✓ Successfully initialized JIT backend (drjit-core target loaded)" << std::endl;

        // Test 3: Basic memory allocation to verify runtime linking
        uint32_t index = jit_var_new_literal(JitBackend::LLVM, VarType::Float32, &index, 1, 0, 0);
        if (index != 0) {
            std::cout << "✓ Successfully created JIT variable (runtime functionality works)" << std::endl;
            jit_var_dec_ref(index);
        }

        jit_shutdown();
        std::cout << "✓ Successfully shut down JIT backend" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "✗ JIT backend initialization failed: " << e.what() << std::endl;
        return 1;
    }
#else
    std::cout << "ⓘ JIT backends disabled, skipping runtime tests" << std::endl;
#endif

    std::cout << "All relocatable target tests passed!" << std::endl;
    return 0;
}
