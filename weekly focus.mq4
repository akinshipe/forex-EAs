
#define     NL    "\n" 



       
extern double lot_size = 0.01;

// this is used to keep track of maximal drawdown and ups
double    MaximalDrawDown = 0;
double    MaximalDrawUp = 0;

int      LastWriteHour = -1;


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
//| Closes all open tarde
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
               
                 
                             
                         
              }           
                         
}



   



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
   
   string currency_list[27] =          {"USDCHF", "GBPUSD", "EURUSD", "USDJPY", "USDCAD", "AUDUSD", "NZDUSD", "GBPCHF", "EURCHF", "CHFJPY", "CADCHF", "AUDCHF", "NZDCHF", "EURGBP", "GBPJPY", "GBPCAD", "GBPAUD", "EURJPY", "EURCAD", "EURAUD", "EURNZD", "CADJPY", "AUDJPY", "NZDJPY", "AUDCAD", "NZDCAD", "AUDNZD"} ;
   
   string trade_currency[27] =         { "yes",      "yes",      "yes",    "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",     "yes",      "yes",     "yes"} ;
   
   string trade_direction[27] =        {  0,         0,         0,       0,        0,        0,        0,         0,        0,        0,       0,        0,         0,       0,        0,         0,        0,       0,         0,       0,         0,        0,        0,       0,         0,        0,        -0   } ;    
                                           
   double ask_price, bid_price;
   
   double profit ;
  
    bool filehandle;
   
   
  
   
   
   
   
//+------------------------------------------------------------------+
//  loops through open orders and perform actions                                      |
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
                
    
     
     
   
        
      
      
       
        
        
        
        // code to trade
       
      if( DayOfWeek()== 1 && Hour()== 1 && Minute() >1  ){
       
      
       // loop through current open orders and turn of trade for currencies already in open position
            for(int b=0; b < 27; b++){
            
                   for( int x=0 ;x < OrdersTotal(); x++ ){
            
            
                        // We select the order of index i selecting by position and from the pool of market/pending trades.
                           OrderSelect( x, SELECT_BY_POS, MODE_TRADES ); 
                             
                           if ( OrderSymbol() == currency_list[b]){
                                    
                                    trade_currency[b] = "no";
                                    
                           } 
                                                       
                   }   
                   
                                   
          }   
      
      
        
            // loop throgh currency list and make trade 
            for(int q=0; q < 27;q++){
             
             
                  if(trade_currency[q] == "yes"){
                  
                  
                                 if(trade_direction[q] == 1){
                                 
                                 
                                                 ask_price = NormalizeDouble(MarketInfo(currency_list[q], MODE_ASK), MarketInfo(currency_list[q], MODE_DIGITS));
                                                                                 
                                                 OrderSend( currency_list[q], OP_BUY, lot_size, ask_price, 20, 0, 0);
                                 
                                                   
                                 
                                 }
                                 
                                 if(trade_direction[q] == -1){
                                 
                                 
                                                 ask_price = NormalizeDouble(MarketInfo(currency_list[q][q], MODE_BID), MarketInfo(currency_list[q], MODE_DIGITS));
                                                                                 
                                                 OrderSend( currency_list[q], OP_SELL, lot_size, ask_price, 20, 0, 0);
                                 
                                                   
                                 
                                 }
                                 
                                 
                  }
                  
                  
    
             
             } 
            
            
                                                    
                                                                                                   
      }
     
     
    
    // calculate current profit or loss and write info to csv if it is the appriopriate time
    
    for( int g=0 ;g < OrdersTotal(); g++ ){
            
            
                        // We select the order of index i selecting by position and from the pool of market/pending trades.
                           OrderSelect( g, SELECT_BY_POS, MODE_TRADES ); 
                             
                                                             
                           profit = profit + OrderProfit() ;
                           
                           
                           
                          
                           // checks if it is the appriorpriate time and then writes to the csv file
                           if(  Minute() == 30 && LastWriteHour != Hour()   ){
     
                                       ResetLastError();
                                       filehandle = FileOpen("weekly_focus_data.csv",FILE_CSV|FILE_READ|FILE_WRITE);
                                       
                                       if(filehandle!=INVALID_HANDLE){
                                       
                                                   FileSeek(filehandle, 0, SEEK_END);
                                                   FileWrite(filehandle, DayOfWeek(),  Hour(), Minute(), OrderSymbol(), OrderType(), OrderProfit(), MarketInfo(OrderSymbol(), MODE_SPREAD)   );
                                                   FileClose(filehandle);
                                                   
                                                   // checking if the loop has finished so that it can store the value of last time to avoid duplicationg rows
                                                   if ( OrdersTotal()- g ==1){
                                                   
                                                             LastWriteHour = Hour();
                                                             Print("FileOpen OK", Hour());
                                                   
                                                   }
                                                  
                                                   
                                                   
                                        }
                        
                                        else Print("Operation FileOpen failed, error ",GetLastError());
     
                            };
                                    
                          
                                    
                                    
                                    
                                    
                                    
                                    
                                                       
     }   
   
   
   
       
    // save current profit or loss if they are above maximal drawdown or drawup
    
    
    
    if( profit > MaximalDrawUp){
    
            MaximalDrawUp = profit;
    
    }
    
    if( profit < MaximalDrawDown){
    
            MaximalDrawDown = profit;
    
    }
    
    
    
     // code to close all trades
     
    if( DayOfWeek()== 5 && Hour()== 23 && Minute() > 50  ){
      
               CloseAll();
               
     }        
     
    
    
           
    Comment(  "DrawUP : ", MaximalDrawUp, NL,
    
              " DrawDown : ", MaximalDrawDown, NL
    
            
             
              );
             
             
    //Sleep(1000);         
   
  
 } // start()

 




