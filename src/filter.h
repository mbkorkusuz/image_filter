#ifndef FILTER_H
#define FILTER_H

#include <stdint.h>

extern "C" {
    void apply_filter1(const char* input_path, const char* output_path, float intensity);  // Sepia
    void apply_filter2(const char* input_path, const char* output_path, float intensity);  // Warm
    void apply_filter3(const char* input_path, const char* output_path, float intensity);  // Cool
    void apply_filter4(const char* input_path, const char* output_path, float intensity);  // Sketch
    void apply_filter5(const char* input_path, const char* output_path, float intensity);  // High Contrast
    void apply_filter6(const char* input_path, const char* output_path, float intensity);  // Fade
    void apply_filter7(const char* input_path, const char* output_path, float intensity);  // Black & White
    void apply_filter8(const char* input_path, const char* output_path, float intensity);  // Vintage
    void apply_filter9(const char* input_path, const char* output_path, float intensity);  // Blur
    void apply_filter10(const char* input_path, const char* output_path, float intensity); // Edge Detection
    void apply_filter11(const char* input_path, const char* output_path, float intensity); // Emboss
    void apply_filter12(const char* input_path, const char* output_path, float intensity); // Negative
}

#endif