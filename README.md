# Biomedical-Image-Analysis-Matlab
This repository contains a specialized collection of projects focused on **Biomedical Engineering** and **Computational Vision**, developed during my studies at the Department of Computer Science and Biomedical Informatics.

---

##  Projects Overview

### 1. Deep Learning & Image Classification 
* **Dataset:** CALTECH101 (101 object categories).
* **Methodology:** Comparative analysis using **Transfer Learning** on pre-trained Convolutional Neural Networks (**AlexNet** & **VGG16**).
* **Key Results:** * Achieved **86.81% accuracy** with VGG16.
    * Performance evaluation via **Confusion Matrices** and **Loss Curves** (Training/Validation).
    * Hyperparameter tuning and convergence analysis.

### 2. Cell Segmentation: Fluorescence Microscopy 
* **Objective:** Automated nuclear segmentation and morphological feature extraction.
* **Technical Pipeline:**
    * Pre-processing: Top-hat filtering and binarization.
    * Segmentation: **Watershed Transformation** combined with **Distance Transform** to resolve overlapping nuclei.
    * Feature Extraction: Calculation of Area, Perimeter, and Axis Symmetry Ratio using `regionprops`.

### 3. Medical Image Registration 
* **Objective:** Geometric alignment of medical image pairs.
* **Algorithm:** Automated **Affine Transformation** based on control point mapping.
* **Evaluation Metrics:** Precision assessment using **Mutual Information (MI)** and **Correlation Coefficient (CC)** before and after registration.

### 4. 3D Computer Vision: Modeling & Projection 
* **Functionality:** Processing and visualization of anatomical 3D data.
* **Highlights:** * **STL file** parsing and triangulation object handling.
    * Implementation of **Perspective Projection** models.
    * 3D Coordinate transformations (Rotation/Translation) to map objects onto a 2D camera plane.

---

##  Tech Stack & Tools
| Category | Tools/Techniques |
| :--- | :--- |
| **Language** | MATLAB |
| **Toolboxes** | Image Processing, Deep Learning, Computer Vision |
| **AI Models** | AlexNet, VGG16, CNNs, Transfer Learning |
| **Algorithms** | Watershed, Affine Registration, K-means |

---

---
All projects listed above were developed as part of the **"Computer Vision"** course curriculum at the University of Thessaly, under the supervision of Prof. K. Delibasis.
