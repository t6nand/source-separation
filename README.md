# source-separation

This project presents an implementation and evaluation of an end-to-end system based on deep learning for speech enhancement based audio source separation, in the monaural voice recordings. Speech Enhancement is achieved by applying a ratio mask to a time-frequency representation of the input signal and through a subsequent reconstruction for the estimated clean speech signal. The mask is estimated from the noisy mixture input data using deep learning machines which are trained on a dataset obtained by additive mixing of recordings of the clean speech and the different sources of noise at a particular signal-to-noise ratio. The expected intelligibility of the reconstructed audio is compared using the intelligibility metric STOI (Short-Time Objective Intelligebility). The quality of estimated clean speech post processing, is compared using the quality metric PESQ (Perceptual Evaluation of Speech Quality), as recommended by the ITU (International Telecommunication Union).

Please go through the project [wiki](https://github.com/t6nand/source-separation/wiki) for background and understanding the process first.

## Getting Started

### Prerequisites
1. [Setup](https://www.mathworks.com/products/get-matlab.html?s_tid=gn_getml)(if not already done) Matlab (version R2019a or higher).
2. [Dataset](https://github.com/t6nand/source-separation/wiki/Dataset). If you want to use your own dataset, this is not required.

### Setting up the project
1. Fork/Clone this repository.
2. Add the project to the Matlab path.
3. Try automated training and testing exercise by using the baseline DNN model for a minimum number of training samples (for example 100) by invoking:
`train_test_model(<path_to_clean_speech_samples>, <path_to_noise_samples>, <numSamples>, <validation_percentage e.g. 0.15 for 15%>, <test percentage e.g. 0.15 for 15%>, <snr at which speech is to be mixed to noise e.g. 0/-2 etc.>, <save_model true/false for saving model as .mat object to local file system>, 1, 1)`
in the matlab command window.
4. If everything works fine, the result of STOI scores for the test subset of the dataset would be shown in the Matlab command window as a result.

### Handeling Errors during project setup: 
1. In case of error while saving the estimated speech samples post training phase, edit the [modelPrediction.m](https://github.com/t6nand/source-separation/blob/master/test/modelPrediction.m) script to include the save paths based on your operating system.
2. In case of error during the training phase with GPU execution environment, please make sure that your system has a compatible GPU and that the latest GPU drivers are installed. If the compatible GPU is not present, change the execution environment to **cpu** in the baseline [model](https://github.com/t6nand/source-separation/blob/master/source_separation/model/dnn.m)

## Contribution
- For trying your own deep learning models and comparing it with the baseline, add the new model to the [model](https://github.com/t6nand/source-separation/blob/master/source_separation/model) directory. 
- If you would wish to try a new set of audio feature extraction, kindly add a class property for the same in the [audio_features.m](https://github.com/t6nand/source-separation/blob/master/source_separation/audio/audio_prep/audio_features.m) and write your extraction method in tune with the existing framework for the same in the class.

If you would like to contribute your work to this project, please generate a pull request. This would help us compare performances of different approaches for speech enhacement based source separation along with you.  
