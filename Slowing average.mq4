//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//|              Close 
//|   Last Updated 12-12-2006 10:00pm
//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#define     NL    "\n" 

extern double    ProfitTarget     = (99999999999.0); // closes all orders once Float hits this $ amount

extern bool   CloseAllNow      = false;          // closes all orders now
extern bool   CloseProfitableTradesOnly = false; // closes only profitable trades
extern double ProftableTradeAmount      = 1;     // Only trades above this amount close out
extern bool   ClosePendingOnly = false;          // closes pending orders only
extern bool   UseAlerts        = false;
extern float   Potentiator = 0;             //this is the degree at which 19:00 bar should be greater than 18:59 bar before it is identified as a swing
extern double lot_size = 0.01;


double    MaximalDrawDown = 0;
double    MaximalDrawUp = 0;

string    MaximalDrawDownTime = "unknown";
string    MaximalDrawUpTime = "unknown";
string    CurrentTime = "unknown";
string    CurrentDay = "unknown";
int      LastWriteTime = 0;
string     can_place_trade = "true";
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
void CloseAll()
{
   
            bool result = false;
            double close_price;
         
            while(OrdersTotal()>0)
            {
              
                  if(OrderSelect(0, SELECT_BY_POS)==true){
         
                           result = false;
                           if ( OrderType() == OP_BUY){
                                       
                                       close_price = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), MarketInfo(OrderSymbol(), MODE_DIGITS)) ;
                           
                                       result = OrderClose( OrderTicket(), OrderLots(), close_price, 999999,  CLR_NONE );
                           }
                           
                           
                           if ( OrderType() == OP_SELL){
                           
                                         close_price = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), MarketInfo(OrderSymbol(), MODE_DIGITS)) ;
                           
                                         result = OrderClose( OrderTicket(), OrderLots(), close_price, 999999,  CLR_NONE );
                            }             
                                         
                           
                           
                           
                  }
                   Print("trade closed" );
                
                  can_place_trade = "true";
                 
            
                        
                         
              }           
                         
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
   int      OrdersBUY;
   int      OrdersSELL;
   double   BuyLots, SellLots, BuyProfit, SellProfit;
   int      DayCode = 8;
   double    LossTarget  = -9999999.0;
   
   
   
   double bar15_close;
   double bar8_close;
   double bar1_close;
   double volatility1;
   double volatility2;
   
   string currency ="EURUSD";
 
   double currency_volatility;
   double ask_price;
   double bid_price;
   
   bool filehandle;
   int order_status = 1;
//+------------------------------------------------------------------+
//  Determine last order price                                       |
//-------------------------------------------------------------------+
      for(int i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
         if(OrderType()==OP_BUY) 
         {
            OrdersBUY++;
            BuyLots += OrderLots();
            BuyProfit += OrderProfit() + OrderCommission() + OrderSwap();
         }
         if(OrderType()==OP_SELL) 
         {
            OrdersSELL++;
            SellLots += OrderLots();
            SellProfit += OrderProfit() + OrderCommission() + OrderSwap();
         }
      }               
      
      
    if(OrdersTotal()>0)
    {
            LossTarget = -1*(BuyLots + SellLots)*500;
    
    }
    
    CurrentTime = (TimeHour(CurTime())-1) + ":" + TimeMinute(CurTime());
    DayCode = DayOfWeek();
    if(DayCode ==0) CurrentDay = "Sunday, " ;
    if(DayCode ==1) CurrentDay = "Monday, " ;
    if(DayCode ==2) CurrentDay = "Tuesday, " ;
    if(DayCode ==3) CurrentDay = "Wednesday, " ;
    if(DayCode ==4) CurrentDay = "Thrsday, " ;
    if(DayCode ==5) CurrentDay = "Friday, " ;
    if(DayCode ==6) CurrentDay = "Saturday, " ;
            
    
    
    
    
    
    if((BuyProfit+SellProfit) < MaximalDrawDown)
    {
            MaximalDrawDown = BuyProfit+SellProfit;
            MaximalDrawDownTime = CurrentDay + CurrentTime;
            
            
           
            
     }       
     
     if((BuyProfit+SellProfit) > MaximalDrawUp)
    {
            MaximalDrawUp = BuyProfit+SellProfit;
            MaximalDrawUpTime = CurrentDay + CurrentTime;
            
     }    
   
    
   if( BuyProfit+SellProfit <= LossTarget)
     {
               CloseAll();
     }
            
    
    if( BuyProfit+SellProfit >= ProfitTarget)
     {
               CloseAll();
     }
     
     if( TimeDayOfWeek(TimeLocal())== 1 && TimeHour(TimeLocal())== 11 && TimeMinute(TimeLocal())== 0  ){
      
               CloseAll();
     }        
     
     
     
     
     
    
    
   
  
             
           bar15_close = NormalizeDouble(iClose(currency,PERIOD_M1,15), 5); 
            bar8_close = NormalizeDouble(iClose(currency,PERIOD_M1,8), 5);
            bar1_close = NormalizeDouble(iClose(currency,PERIOD_M1,1), 5);
            volatility1 = bar1_close - bar8_close;
            volatility2 = bar8_close - bar15_close;
            
            if ( volatility2 == 0 || volatility1==0 ){
                  currency_volatility= 0;
                  
            }
            else{
                   currency_volatility = MathAbs(volatility1)/ MathAbs(volatility2);
             }   
            
                           
            
       
            if(currency_volatility > Potentiator && can_place_trade == "true"  && TimeDayOfWeek(TimeLocal())== 5 && TimeHour(TimeLocal())== 17 && TimeMinute(TimeLocal())== 0  ){
            
                                
                    if( volatility1 < 0){
                                                   
                                ask_price = NormalizeDouble(MarketInfo(currency, MODE_ASK), MarketInfo(currency, MODE_DIGITS));
                                                   
                               order_status =  OrderSend( currency, OP_BUY, lot_size, ask_price, 10, 0, 0, "volatility : " + DoubleToStr( currency_volatility), 0, 0, clrGreen);
                               if(order_status == -1) can_place_trade = false;
                                                               
                      }
                      
                      if( volatility1 > 0){
                                                   
                                 bid_price = NormalizeDouble(MarketInfo(currency, MODE_BID), MarketInfo(currency, MODE_DIGITS));
                                                   
                                 order_status =  OrderSend( currency, OP_SELL, lot_size, bid_price, 10, 0, 0, "volatility : " + DoubleToStr( currency_volatility), 0, 0, clrGreen);
                                  
                                  
                                                               
                        }
                        
                        
                        
                        
                         if(order_status == -1) {
      
                               can_place_trade = "true";
                           }          
                            else{
                                   can_place_trade = "false";
                             }
     
                                       
                          
     
              }
     
     
     
     
     
     
      if( OrdersTotal()>0 && LastWriteTime != TimeMinute(TimeLocal())  && (TimeMinute(TimeLocal())==7||TimeMinute(TimeLocal())==22 ||TimeMinute(TimeLocal())==37 ||TimeMinute(TimeLocal())==52)   ){
     
                        ResetLastError();
                        filehandle = FileOpen("laolu1_ea.csv",FILE_CSV|FILE_READ|FILE_WRITE);
                        if(filehandle!=INVALID_HANDLE){
                                    FileSeek(filehandle, 0, SEEK_END);
                                    FileWrite(filehandle, "start at 5pm , compare (bar8-bar7 to bar8-bar15))",(SellLots + BuyLots), TimeYear(TimeLocal()), TimeDayOfWeek(TimeLocal()),TimeDay(TimeLocal()), TimeHour(TimeLocal()), TimeMinute(TimeLocal()),TimeHour(TimeLocal())- TimeHour(TimeGMT()), Potentiator, BuyProfit+SellProfit );
                                    FileClose(filehandle);
                                    LastWriteTime = TimeMinute(TimeLocal());
                                    Print("FileOpen OK");
                          }
                        
                         else Print("Operation FileOpen failed, error ",GetLastError());
     
     };
   
     
     
     
     //Print("higeest");
    // Print( currency_volatility[0][0]);
    //  Print(currency_volatility[1][0]);
    // Print(currency_volatility[2][0]);
     // Print(" today : ", DayOfWeek());
     //  Print(" hour : ", Hour());
         // Print(" minute : ", Minute());
          //Sleep(1000)  ;
       
           
       
   
   Comment(
                                                                                 
           "                                                                          Profit Target    ", ProfitTarget, NL,
           "                                                                          Loss Target    ", LossTarget, NL,
           "                                                                          Maximal Draw Down    ", MaximalDrawDown, NL,
           "                                                                          Maximal Draw Down Ttme    ", MaximalDrawDownTime, NL,
           "                                                                          Maximal Draw Up    ", MaximalDrawUp, NL,
           "                                                                          Maximal Draw Up Time    ", MaximalDrawUpTime, NL,
           "                                                                          Lot        ", (SellLots + BuyLots), "         ", currency_volatility, NL
           "                                                                          Current Server Time  ",TimeHour(CurTime()),":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()),NL
           "                                                                              can place trade :  ", can_place_trade
           );
 } // start()

 




