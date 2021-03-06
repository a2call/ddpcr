# ddPCR R package - Dean Attali 2015
# --- Dataset tab UI --- #

tabPanel(
  title = "Dataset",
  id    = "datasetTab",
  value = "datasetTab",
  name  = "datasetTab",
  class = "fade in",
  icon  = icon("table"),
  
  tabsetPanel(
    id = "datasetTabs", type = "tabs",    
    
    # tab for uploading a new dataset ----
    tabPanel(
      title = "Upload new dataset",
      id = "newDatasetTab",
      h3(strong("Upload data from QuantaSoft "),
         helpPopup("To use this tool, you must first export the data from QuantaSoft to <i>.csv</i> (Excel) files")
      ),
      br(),
      fileInput(
        "uploadDataFiles",
        div("Data files",
            helpPopup('These are all the files exported by QuantaSoft with names ending in "_Amplitude"'),
            br(), downloadLink("sampleDataFile", "Example data file")
        ),
        multiple = TRUE,
        accept = c(
          'text/csv',
          'text/comma-separated-values',
          '.csv'
        )
      ),
      fileInput(
        "uploadMetaFile",
        div("Main results file (optional)",
            helpPopup("This is the Excel file exported by QuantaSoft that contains the main results for every well."),
            br(), downloadLink("sampleResultsFile", "Example results file")
        ),
        multiple = FALSE,
        accept = c(
          'text/csv',
          'text/comma-separated-values',
          '.csv'
        )
      ),
      
      withBusyIndicator(
        actionButton(
          "uploadFilesBtn",
          "Upload data",
          class = "btn-primary"
        )
      )
    ),
    
    # tab for loading existing dataset ----
    tabPanel(
      title = "Load saved dataset",
      id = "loadDatasetTab",
      h3(strong("Upload previously saved data"),
         helpPopup(paste0(
           "If you've previously used this tool to save data (using the",
           strong(icon("download"), "Save data"),
           "button), you can load it here")
         )),
      br(),
      fileInput(
        "loadFile",
        "Saved ddPCR file",
        multiple = FALSE,
        accept = c(
          '.rds'
        )
      ),
      withBusyIndicator(
        actionButton(
          "loadFileBtn",
          "Load data",
          class = "btn-primary"
        )
      )
    ),
    
    # tab for loading sample dataset ----
    tabPanel(
      title = "Use sample dataset",
      id = "sampleDatasetTab",
      h3(strong("Use sample dataset")),
      br(),
      selectInput("sampleDatasetType", "Choose a dataset to load",
                  c("Small dataset" = "small", "Large dataset" = "large")
      ),
      br(),
      withBusyIndicator(
        actionButton(
          "loadSampleBtn",
          "Load data",
          class = "btn-primary"
        )
      )
    )
  )
)