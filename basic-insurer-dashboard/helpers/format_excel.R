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
      style = createStyle(textDecoration = "underline", halign = "center"),
      rows = row,
      cols = col
    )
  }
  
  #' create_header_row
  #' 
  #' @param wb The excel workbook
  #' @param sheet The sheet of the workbook
  #' @param x A list of the form list(list(name, 1), list(name, 3))
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
  
  return(list(
    "create_header" = create_header,
    "create_header_row" =create_header_row
  ))
})()