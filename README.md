# source-separation

This project aims at monaural speech separation using deep learning, where a speech audio is mixed with some interfering signal at some SNR levels (as a proof of concept, mixtures are tried at 0 SNR and -2 SNR). The estimation of separated speech audio is the evaluated for intelligebility using STOI scores and for quality by PESQ scores respectively.

## Dataset

### Clean Speech dataset: TIMIT

### Noise dataset: MUSAN

### Training target: Ideal Ratio Mask (IRM) 
IRM is calculated using spectrogram and/or cochleagram.
                     
#### Note: 
IRM can be thresholded based on some local criterion 
to obtain a binary mask. As a proof of concept, IRM to IBM
calculation is also made available.

## Models Used:

### Feed forward Deep Neural Network:
        
        input neurons: depends on features extracted
        
```
DNN_0: 
    Imageinput(<variable nodes>)
    Fully Connected Layer(1024), batchnormalization,reLU
    Fully Connected Layer(1024), batchnormalization,reLU
    Fully Connected Layer(1024), batchnormalization,reLU
    Fully Connected Layer(1024), batchnormalization,reLU
    Fully Connected Layer(<variable nodes>), regressionLayer
```
```        
DNN_1: 
    Imageinput(<variable nodes>)
    Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%)
    Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%)
    Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%)
    Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%)
    Fully Connected Layer(<2*variable_nodes>),biasedSigmoidLayer, regressionLayer
```
        
### Convolutional Neural Network:

       input neurons: depends on size of spectrogram/cochleagram.
       
```
CNN_0:
    Imageinput(<variable nodes>)
    convolutional2d Layer(11x11 filter size, <variable nodes> filters), batchnormalization, leaky reLU(scale 0.01)
    convolutional2d Layer(11x11 filter size, <variable nodes> filters), batchnormalization, leaky reLU(scale 0.01), maxpool(3x3 pooling size and stride 1x1 and same padding)
    convolutional2d Layer(11x11 filter size, <variable nodes> filters), batchnormalization, leaky reLU(scale 0.01)
    convolutional2d Layer(11x11 filter size, <variable nodes> filters), batchnormalization, leaky reLU(scale 0.01), maxpool(3x3 pooling size and stride 1x1 and same padding)
    fully connected Layer(<variable nodes>), leaky reLU(scale 0.01), dropout(20%), regressionLayer.
```
       
```
CNN_1: 
    Imageinput(<variable nodes>)
    convolutional2d Layer(3x3 filter size, 12 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) 
    convolutional2d Layer(3x3 filter size, 24 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) 
    convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) 
    convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU 
    convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU, dropout(20%) 
    Fully connected layer(<variable nodes>), regressionLayer.
```
       
       
 ### Performance Analysis: 

[Available](https://github.com/t6nand/source-separation/blob/master/analysis/performance_analysis.pdf) in analysis folder of the root directory of the project. 
