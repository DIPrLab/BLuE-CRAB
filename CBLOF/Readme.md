To get the dataset to run the experiments, 

## Dataset

For the dataset, 
* Click on [ble-doubt](https://github.com/jeb482/bledoubt/blob/main/analysis/anonymized_logs.zip) to access the anonymized datasets from the BLE-doubt repo
* Download the zip file and extract all the datasets from it.
* Make sure the datasets are stored in the CBLOF folder

## Running CBLOF and getting contents of Table 1 (CBLOF-based detection)

To run CBLOF, 
* Navigate to the CBLOF folder 
* Click on the Jupyter notebook file  named cblof_ipynb in this folder
* Execute all the cells in the notebook by clicking on **Run All**
* When you run cblof_model.ipynb, the CBLOF-based detection part of Table 1 is displayed in the confusion matrix, and the cells before it show the precision, recall, and F1score.
* For the BLE-Doubt, you would have to run the code in their repo.
* I manually entered Table 1 in LaTeX.
  


To run BLE-Doubt and obtain the results in Table 1(BLE-Doubt part of the table),
*  Click on [repo](https://github.com/jeb482/bledoubt/tree/main/analysis), and then run the Python script called bledoubt_analysis.py

For Figure 3, 
* Currently, you won't be able to assess Figure 3 as the data for those plots are not anonymized.

For Figure 4,
* Navigate to the CBLOF folder 
* Click on the Jupyter notebook file  named plot_4ab.ipynb in this folder
* Execute all the cells in the notebook by clicking on **Run All**
 
