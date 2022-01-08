//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//|              Close 
//|   Last Updated 12-12-2006 10:00pm
//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#define     NL    "\n" 

int      last_write_hour = -1000;

int      last_write_minute = -1000;







//+-------------+
//| Custom init |
//|-------------+
int init()
  {

  }

//+----------------+
//| Custom DE-init |
//+----------------+
int deinit()
  {

  }

//+------------------------------------------------------------------------+
//| Closes everything
//+------------------------------------------------------------------------+
int get_spread()
{
   
               string currency_list[27] =          {"USDCHF", "GBPUSD", "EURUSD", "USDJPY", "USDCAD", "AUDUSD", "NZDUSD", "GBPCHF", "EURCHF", "CHFJPY", "CADCHF", "AUDCHF", "NZDCHF", "EURGBP",
                                                 "GBPJPY", "GBPCAD", "GBPAUD", "EURJPY", "EURCAD", "EURAUD", "EURNZD", "CADJPY", "AUDJPY", "NZDJPY", "AUDCAD", "NZDCAD", "AUDNZD"} ;
               int total_spread = 0 ;
   
               for(int a=0; a < 27; a++){
               
                     
               
                     total_spread = total_spread + MarketInfo( currency_list[a] , MODE_SPREAD);
                     
                     
                      
               }
               
               
             //  Print( currency_list[a], " Spread value in points=", total_spread);
   
               return(total_spread);
   
                         
}
   
//+------------------------------------------------------------------------+
//| cancels all orders that are in profit
//+------------------------------------------------------------------------+


//+------------------------------------------------------------------------+
//| cancels all pending orders 
//+------------------------------------------------------------------------+







//+-----------+
//| Main      |
//+-----------+
int start()
  {
  
  
  int returned_total_spread;
  bool filehandle;
  string today;
  
         
         if(  ( Minute() == 0 || Minute() == 30)  &&  (last_write_hour != Hour()|| last_write_minute != Minute() )  )  
         {
                       
                       
                       //determining what day today is
                      
                       
                        if ( DayOfWeek() == 0){ today = "SUN";}
                        if ( DayOfWeek() == 1){ today = "MON";}
                        if ( DayOfWeek() == 2){ today = "TUE";}
                        if ( DayOfWeek() == 3){ today = "WED";}
                        if ( DayOfWeek() == 4){ today = "THUR";}
                        if ( DayOfWeek() == 5){ today = "FRI";}
                        if ( DayOfWeek() == 6){ today = "SAT";}
                               
        
                        returned_total_spread = get_spread();
                        
                  
                         ResetLastError();
                         
                         filehandle = FileOpen("total_swap.csv",FILE_CSV|FILE_READ|FILE_WRITE,',');
                         
                   
                         if(filehandle!=INVALID_HANDLE)
                         {
                         
                         
                         
                                           // checks if this is the first write of the week so as to write the headers of each column
                         
                                        if( last_write_hour == -1000)
                                        {
                                                      
                                                        FileSeek(filehandle, 0, SEEK_END);
                                                        FileWrite(filehandle, "DAY", "HOUR", "MINUTE", "TOTAL SPREAD"   );
                                                        
                                                                  
                                                        // checking if the loop has finished so that it can store the value of last time to avoid duplicationg rows
                                                        
                                                                                              
                                                                  
                                         }
                         
                         
                                       // writes the needed information to file
                                        FileSeek(filehandle, 0, SEEK_END);
                                        FileWrite(filehandle, today,  Hour(), Minute(), returned_total_spread   );
                                        
                                                   
                                         
                                                                               
                                                   
                          }
                        
                   
                        FileClose(filehandle);
                        last_write_hour = Hour();
                        last_write_minute = Minute();
                        Print("Data Saved Succeesfully : ", today, " ",  Hour(), ":", Minute(), " spread is : ",  returned_total_spread);
  
         }
  
  
  
  
  
         
         
   Comment(  "Current Server Time  ",TimeHour(CurTime()),":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()),NL );
   
   
   Sleep(9200); 
                                                                
 } // start()

 




