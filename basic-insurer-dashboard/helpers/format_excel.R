#helpers to format excel workbook

(function() {
  #' create_header
  #' 
  #' @param wb The excel workbook
  #' @param sheet The sheet of the workbook
  #' @param name The name of the new header
  #' @param row The row of the cell
  #' @param col The column of the cell
  #' @param col_span The number of columns the header covers
  #' 
  #' @description This function writes a header that can cover multiple columns.
  #' To create a row of headers like this, use create_header_row
  create_header <- function(wb, sheet, name, row, col, col_span = 1) {
    #row, col define the start of the header
    #the header spans the next col_span columns
    writeData(
      wb,
      sheet,
      name,
      startCol = col,
      startRow = row
    )
    mergeCells(
      wb,
      sheet,
      cols = col:(col + col_span - 1),
      rows = row
    )
    addStyle(
      wb,
      sheet,
      style = createStyle(
        textDecoration = c("underline", "bold"), 
        halign = "center"
      ),
      rows = row,
      cols = col
    )
  }
  
  #' create_header_row
  #' 
  #' @param wb The excel workbook
  #' @param sheet The sheet of the workbook
  #' @param x A list of the form `list(list("col_name", 1), list("col_name_2", 3))`. Where the first element in 
  #' each list is the column name and the second element is the number of columns that the header should span over.
  #' @param startRow The row this function will write to 
  #' @param startCol The column where this row of names will start
  #' 
  #' @description This function takes in a list to execute create_header
  #' multiple times on a single row
  create_header_row <- function(wb, sheet, x, startRow, startCol) {
    for (i in seq_along(x)) {
      name_num <- x[[i]]
      create_header(wb, sheet, name_num[[1]], row = startRow, col = startCol, col_span = name_num[[2]])
      startCol <- startCol + name_num[[2]]
    }
  }
  
  #' exhibit_header_right
  #' 
  #' @param wb The excel workbook
  #' @param sheet The sheet of the workbook
  #' @param start_row The first row of the headers
  #' @param start_col The column of the headers
  #' @param x A vector of strings to be written to the workbook
  #' 
  #' @description This function writes a column of text aligned to the right
  #' anywhere in an excel workbook
  exhibit_header_right <- function(wb, sheet, start_row, start_col, x) {
    writeData(
      wb = wb,
      sheet = sheet,
      x = x,
      startRow = start_row,
      startCol = start_col
    )
    
    addStyle(
      wb,
      sheet = sheet,
      rows = start_row:(start_row + length(x) - 1),
      cols = start_col,
      style = createStyle(halign = "right")
    )
  }
  
  return(list(
    "create_header" = create_header,
    "create_header_row" =create_header_row,
    "exhibit_header_right" = exhibit_header_right
  ))
})()