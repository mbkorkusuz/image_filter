#include <opencv2/opencv.hpp>
#include "filter.h"

extern "C" {

void apply_filter1(const char* input_path, const char* output_path, float intensity) {
    // Sepia Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat sepiaKernel = (cv::Mat_<float>(3,3) <<
        0.272, 0.534, 0.131,
        0.349, 0.686, 0.168,
        0.393, 0.769, 0.189);
    cv::transform(image, image, sepiaKernel);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter2(const char* input_path, const char* output_path, float intensity) {
    // Warm Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat warmKernel = (cv::Mat_<float>(3,3) <<
        1.05, 0.00, 0.00,
        0.00, 1.00, 0.00,
        0.00, 0.00, 0.95);
    cv::transform(image, image, warmKernel);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter3(const char* input_path, const char* output_path, float intensity) {
    // Cool Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat coolKernel = (cv::Mat_<float>(3,3) <<
        0.95, 0.00, 0.00,
        0.00, 1.00, 0.00,
        0.00, 0.00, 1.05);
    cv::transform(image, image, coolKernel);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter4(const char* input_path, const char* output_path, float intensity) {
    // Sketch Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat gray, inv, blur, sketch;
    
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    cv::bitwise_not(gray, inv);
    cv::GaussianBlur(inv, blur, cv::Size(21, 21), 0);
    cv::divide(gray, 255 - blur, sketch, 256.0);
    
    cv::cvtColor(sketch, image, cv::COLOR_GRAY2BGR);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter5(const char* input_path, const char* output_path, float intensity) {
    // High Contrast Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    
    // Contrast ayarı için intensity kullan
    float contrast = 1.0 + (0.5 * intensity); // 1.0 - 1.5 arası
    cv::Mat contrastKernel = (cv::Mat_<float>(3,3) <<
        contrast, 0.0, 0.0,
        0.0, contrast, 0.0,
        0.0, 0.0, contrast);
    cv::transform(image, image, contrastKernel);
    
    cv::imwrite(output_path, image);
}

void apply_filter6(const char* input_path, const char* output_path, float intensity) {
    // Fade Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    
    // Fade miktarı için intensity kullan
    float fade = 1.0 - (0.3 * intensity); // 1.0 - 0.7 arası
    cv::Mat fadeKernel = (cv::Mat_<float>(3,3) <<
        fade, 0.0, 0.0,
        0.0, fade, 0.0,
        0.0, 0.0, fade);
    cv::transform(image, image, fadeKernel);
    
    cv::imwrite(output_path, image);
}

void apply_filter7(const char* input_path, const char* output_path, float intensity) {
    // Black & White Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    cv::cvtColor(gray, image, cv::COLOR_GRAY2BGR);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter8(const char* input_path, const char* output_path, float intensity) {
    // Vintage Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat vintageKernel = (cv::Mat_<float>(3,3) <<
        0.393, 0.769, 0.189,
        0.349, 0.686, 0.168,
        0.272, 0.534, 0.131);
    cv::transform(image, image, vintageKernel);
    
    // Vintage karartma efekti - intensity'ye göre ayarla
    cv::Mat overlay = cv::Mat::zeros(image.size(), image.type());
    cv::rectangle(overlay, cv::Point(0, 0), cv::Point(image.cols, image.rows), 
                  cv::Scalar(20 * intensity, 15 * intensity, 10 * intensity), -1);
    cv::addWeighted(image, 1.0 - (0.15 * intensity), overlay, 0.15 * intensity, 0, image);
    
    // Orijinal ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter9(const char* input_path, const char* output_path, float intensity) {
    // Blur Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    
    // Blur miktarı için intensity kullan
    int blurSize = static_cast<int>(5 + (20 * intensity)); // 5-25 arası
    if (blurSize % 2 == 0) blurSize++; // Tek sayı olması gerekiyor
    
    cv::GaussianBlur(image, image, cv::Size(blurSize, blurSize), 0);
    
    cv::imwrite(output_path, image);
}

void apply_filter10(const char* input_path, const char* output_path, float intensity) {
    // Edge Detection Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat gray, edges;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
    // Threshold değerlerini intensity'ye göre ayarla
    double lowThreshold = 50 + (100 * intensity);   // 50-150 arası
    double highThreshold = 100 + (200 * intensity); // 100-300 arası
    
    cv::Canny(gray, edges, lowThreshold, highThreshold);
    cv::cvtColor(edges, image, cv::COLOR_GRAY2BGR);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter11(const char* input_path, const char* output_path, float intensity) {
    // Emboss Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::Mat gray, emboss;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
    // Emboss kernel - intensity'ye göre güçlendir
    cv::Mat kernel = (cv::Mat_<float>(3,3) <<
        -2 * intensity, -1 * intensity,  0,
        -1 * intensity,  1,  1 * intensity,
         0,  1 * intensity,  2 * intensity);
    
    cv::filter2D(gray, emboss, -1, kernel);
    cv::cvtColor(emboss, image, cv::COLOR_GRAY2BGR);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

void apply_filter12(const char* input_path, const char* output_path, float intensity) {
    // Negative Filter
    cv::Mat image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (image.empty()) return;
    
    cv::Mat original = image.clone();
    cv::bitwise_not(image, image);
    
    // Intensity ile blend
    cv::addWeighted(original, 1.0 - intensity, image, intensity, 0, image);
    
    cv::imwrite(output_path, image);
}

}