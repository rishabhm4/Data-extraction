BOTH <- function(da1,da2)
{
  Totaldata <- NULL
 library(lubridate)
  date1 <- dmy(da1) #DATE1
  
## dayz <- strftime(date1,"%d") monz <- month(date1,label=TRUE) yearz <- format(as.Date(date1, format="%d-%m-%Y"),"%Y")


##datz1 <- paste0(dayz,"-",monz,"-",yearz)

d1 <- dmy(da1)
d2 <- dmy(da2)

dayz1 <- strftime(d2,"%d") #DATE2
monz1<- strftime(d2,"%m")
yearz1 <- format(as.Date(d2,format="%d-%m-%Y"),"%Y")


datz2 <- paste0(monz1,"/",dayz1,"/","/",yearz1)


dates <- seq(as.Date(d1), as.Date(d2), by=1)

for(i in 1:length(dates))
{
  
  DAY <- strftime(dates[i],"%d") #DATE2
  MON<- strftime(dates[i],"%m")
  YEA <- format(as.Date(dates[i],format="%d-%m-%Y"),"%Y")
  DAT <- paste0(MON,"/",DAY,"/",YEA)
  
  
#d <- "http://agmarknet.gov.in/SearchCmmMkt.aspx?Tx_Commodity=4&Tx_State=KK&Tx_District=0&Tx_Market=0&DateFrom=01/01/2014&DateTo=02/01/2014&Fr_Date=01/01/2014&To_Date=02/01/2014&Tx_Trend=2&Tx_CommodityHead=Maize&Tx_StateHead=Karnataka&Tx_DistrictHead=--Select--&Tx_MarketHead=--Select--"
 
d<- paste0("http://agmarknet.gov.in/SearchCmmMkt.aspx?Tx_Commodity=4&Tx_State=KK&Tx_District=0&Tx_Market=0&DateFrom=",DAT,"&DateTo=",
datz2,"&Fr_Date=",DAT,"&To_Date=",datz2,"&Tx_Trend=2&Tx_CommodityHead=Maize&Tx_StateHead=Karnataka&Tx_DistrictHead=--Select--&Tx_MarketHead=--Select--")
library(XML)
a <- readHTMLTable(d,header=TRUE)
#tryCatch(a[[1]],error=function(e) flag <<- FALSE)
#if(flag ==FALSE) {next}
#tryCatch(a[[1]],error=function(e) flag<<- FALSE)
#if(!flag)
#{next}

b <- as.data.frame(a[[1]])

# <- b[1:(length(b[,1])-2),]
 ##To remove the last two rows having total of the state
b <- b[!(b[,1]=="-"),]
library(zoo)
b$`Reported Date` <- na.locf(b$`Reported Date`)



b <-  cbind(b, DATE = rep(dates[i])) ##ADDING DATE

wee <- week(strftime((dates[i])))

b <- cbind(b,WEEK = rep(wee))





mon <- month((dates[i]),label=TRUE)

b <- cbind(b,MONTH = rep(mon)) ##ADDING MONTH




y <- year((dates[i]))

b <- cbind(b,YEAR = rep(y)) ##ADDING YEAR



Totaldata <- rbind(Totaldata,b)

}
Totaldata$`Arrivals (Tonnes)`<- gsub(",", "", Totaldata$`Arrivals (Tonnes)`) 
Totaldata$`Arrivals (Tonnes)`<- as.numeric(Totaldata$`Arrivals (Tonnes)`)

Totaldata$`Min Price (Rs./Quintal)`<- gsub(",", "", Totaldata$`Min Price (Rs./Quintal)`) 
Totaldata$`Max Price (Rs./Quintal)`<- gsub(",","",Totaldata$`Max Price (Rs./Quintal)`)
Totaldata$`Min Price (Rs./Quintal)`<- as.numeric(Totaldata$`Min Price (Rs./Quintal)`)
Totaldata$`Max Price (Rs./Quintal)` <- as.numeric(Totaldata$`Max Price (Rs./Quintal)`)
Totaldata$`Modal Price (Rs./Quintal)`=rowMeans(Totaldata[,c("Max Price (Rs./Quintal)", "Min Price (Rs./Quintal)")], na.rm=TRUE)




Totaldata <- Totaldata[!(Totaldata[,1]=="-"),]


#e <- cbind(DATE = q$`Reported Date`,District = q$`District Name`,Arrival = q$`Arrivals (Tonnes)`,WEEK=q$WEEK, MONTH = q$MONTH , YEAR =q$YEAR)


library(rJava)
library(xlsxjars)
library(xlsx)
write.xlsx(Totaldata,"Arrivepricema.xlsx")

}



library(rJava)
library(xlsxjars)
library(xlsx)
library(readxl)
getwd()
setwd("C:/Users/Dinu Level A/Desktop")
b <- read.xlsx("Arrivepricema.xlsx",sheetIndex = 1)
head(b)

###DISTRICT SELECTION

b <- b[b[,3]=="Bagalkot",]
B <- aggregate(b$`Arrivals (Tonnes)`~b$WEEK+b$YEAR+b$`District Name`, data=b, FUN=sum) 

B<-`colnames<-`(B,c("Week","year","District","Arrival(Tonnes)"))


G <- aggregate( b$`Modal Price (Rs./Quintal)`~b$WEEK+b$YEAR, data=b, FUN=mean) 
G <- `colnames<-`(G,c("WEEK","YEAR","Modal price"))

d <- round(G$`Modal price`)
M <- cbind(B,d)


M<-`colnames<-`(M,c("Week","year","District","Arrival(Tonnes)","Modal price"))



##STATE

B <- aggregate(b$`Arrivals (Tonnes)`~b$WEEK+b$YEAR, data=b, FUN=sum) 

B<-`colnames<-`(B,c("Week","year","Arrival(Tonnes)"))



G <- aggregate( b$`Modal Price (Rs./Quintal)`~b$WEEK+b$YEAR, data=b, FUN=mean) 
G <- `colnames<-`(G,c("WEEK","YEAR","Modal price"))

d <- round(G$`Modal price`)
M <- cbind(B,d)

M<-`colnames<-`(M,c("Week","year","Arrival(Tonnes)","Modal price"))



f <- M
t <- paste0(M$Week,"th week,",M$year)
v <- cbind(M,t)
g<-`colnames<-`(v,c("Week","year","Arrival(Tonnes)","Modal price","Weeks"))

##ARRIVAL
library(plotly)
library(dplyr)
p <- plot_ly(M, x = ~Week, y = ~`Arrival(Tonnes)`,type= "area",mode = 'marker',
             marker = list(size = 10),name ="Weekly Arrival",color= M$Week) %>%
  add_annotations(x =M$Week,
                  y = M$`Arrival(Tonnes)`,
                  text = M$`Arrival(Tonnes)`,
                  xref = "x",
                  yref = "y",
                  showarrow = TRUE,
                  
                  arrowsize = .01,
                  ax = 0,
                  ay = -20,
                  font = list(color = '#264E86',
                              family = 'sans serif',
                              size = 12)) %>% layout(title="Weekly Arrivals")


##MODEL PRICE
mp <- plot_ly(M, x = ~Week, y = ~`Modal price`,type= "area",mode = 'marker',
        marker = list(size = 10),name ="Weekly Model price",color=M$Week) %>%
  add_annotations(x = M$Week,
                  y = M$`Modal price`,
                  text = M$`Modal price`,
                  xref = "x",
                  yref = "y",
                  showarrow = TRUE,
                  
                  arrowsize = .01,
                  ax = 0,
                  ay = -20,
                  font = list(color = '#264E86',
                              family = 'sans serif',
                              size = 12)) %>% layout(title="Weekly model price")
##ARRIVE AND PRICE
ay <- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "Modal price"
)
p <- plot_ly(M, x = ~Week, y = ~`Arrival(Tonnes)`,type= "bar",mode = 'marker',
             marker = list(size = 10),name="Weekly Arrival") %>%
  add_lines(x = ~Week, y = ~`Modal price`, name = "Weekly Modal prices",type="area", marker = list(size = 10), yaxis = "y2",mode="marker") %>%
  layout(
    title = "Model price vs Arrivals in Weeks", yaxis2 = ay,
    xaxis = list(title="Weeks") ) %>%   layout(legend = list(x = 300, y = 1.1), images = list(
        source =  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQZbxpzMhM-bTGzcJWzHK_8FZCxNQAqr8TVNreXVs2G4hCtTBoPA",
        xref = "x",
        yref = "y",
        x = 1,
        y = 3,
        sizex = 2,
        sizey = 2,
        sizing = "stretch",
        opacity = 0.4,
        layer = "below")

)

#'pie', 'contour', 'scatterternary', 'sank
#ey', 'scatter3d', 'surface', 'mesh3d', 'scattergeo', 
#'choropleth', 'scattergl', 'pointcloud', 'heatmapgl', 'parcoords', 'scattermapbox', 'carpet', 
#'scattercarpet', 'contourcarpet', 'ohlc', 'candlestick', 'area'

m
plot_ly(m,x=~m$`Import Price parity at Haldia`,y=~m$`Import Margin (INR/MT)`)
dygraph(m,xlab = ~m$`Import Price parity at Haldia`,ylab=~m$`Import Margin (INR/MT)`)
dygraph()

fl <- cbind(m$`Import Margin (INR/MT)`,m$`Import Margin (USD/MT)`)
dygraph(m, main = "hi") %>%  dyOptions(fillGraph = TRUE, fillAlpha = 0.4)
