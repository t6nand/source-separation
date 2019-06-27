# source-separation
Audio Source separation based on deep learning.

Clean Speech dataset: TIMIT

Noise dataset: MUSAN

Models Used:

Feed forward Deep Neural Network:
        
        input neurons: depends on features extracted
        
        DNN_0: Imageinput(<variable nodes>) + Fully Connected Layer(1024), batchnormalization,reLU + Fully Connected   Layer(1024), batchnormalization,reLU + Fully Connected Layer(1024), batchnormalization,reLU + Fully Connected Layer(1024), batchnormalization,reLU + Fully Connected Layer(121), regressionLayer
        
        DNN_1: Imageinput(<variable nodes>) + Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%) + Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%) + Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%) + Fully Connected Layer(<2*variable_nodes>), biasedSigmoidLayer, batchnormalization,dropout(10%) + Fully Connected Layer(<2*variable_nodes>),biasedSigmoidLayer, regressionLayer
        
Convolutional Neural Network:

       input neurons: depends on size of spectrogram/cochleagram.
       
       CNN_0: Imageinput(<variable nodes>) + convolutional2d Layer(11x11 filter size, 121/64 filters), batchnormalization, leaky reLU(scale 0.01) + convolutional2d Layer(11x11 filter size, 121/64 filters), batchnormalization, leaky reLU(scale 0.01), maxpool(3x3 pooling size and stride 1x1 and same padding) + convolutional2d Layer(11x11 filter size, 121/64 filters), batchnormalization, leaky reLU(scale 0.01) + convolutional2d Layer(11x11 filter size, 121/64 filters), batchnormalization, leaky reLU(scale 0.01), maxpool(3x3 pooling size and stride 1x1 and same padding) +  fully connected Layer(64/121), leaky reLU(scale 0.01), dropout(20%), regressionLayer.
       
       CNN_1: Imageinput(<variable nodes>) + convolutional2d Layer(3x3 filter size, 12 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) + convolutional2d Layer(3x3 filter size, 24 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) + convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU, maxPool(3x3, stride 2x2 and same padding) + convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU + convolutional2d Layer(3x3 filter size, 48 filters), batchnormalization, reLU, dropout(20%) + Fully connected layer(<>), regressionLayer. 
       
       
 Performance Analysis: available in analysis folder.
