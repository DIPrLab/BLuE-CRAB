To get the dataset to run the experiments, 

## Dataset to run annd get the results stored in Table 2

For the dataset, 
* Click on [ble-doubt](https://github.com/jeb482/bledoubt/blob/main/analysis/anonymized_logs.zip) to access the anonymized datasets from the BLE-doubt repo
* Download the zip file and extract all the datasets from it.
* Create a folder called 'bledoubt_data' and store all the dataset
* Make sure the 'bledoubt_data' folder is stored in the CBLOF folder

## Running CBLOF and getting contents of Table 2 (CBLOF-based detection)

To run CBLOF, 
* Navigate to the CBLOF folder 
* Click on the Jupyter notebook file  named cblof_ipynb in this folder
* Execute all the cells in the notebook by clicking on **Run All**
* When you run cblof_model.ipynb, the CBLOF-based detection part of Table 1 is displayed in the confusion matrix, and the cells before it show the precision, recall, and F1score.
* For the BLE-Doubt, you would have to run the code in their repo.
* I manually entered Table 1 in LaTeX.
  

## Running BLE-Doubt and getting contents of Table 1 (BLE-Doubt detection)

To run BLE-Doubt and obtain the results in Table 1(BLE-Doubt part of the table),
*  Click on [repo](https://github.com/jeb482/bledoubt/tree/main/analysis), and then run the Python script called bledoubt_analysis.py

## Running Our Collected Dataset for Figure 3a, b and c

* The dataset we collected has been anonymized and stored in a folder called "our_data".
* To run Figure 3a, b annd c,
* Open cblof_model.ipynb, and change the file path for the dataset file to 'our_data/{log_file_path}' and ground truth file to 'our_data/gt_macs.json'
* Uncomment the last two cells in cblof_model.ipynb the click **Run All** to execute all the cell. The results for Figure 3a, b and c will be displayed in the output of the last cell

For Figure 4a,
* Navigate to the CBLOF folder 
* Click on the Jupyter notebook file  named plot_4ab.ipynb in this folder
* Execute all the cells in the notebook by clicking on **Run All**
 
