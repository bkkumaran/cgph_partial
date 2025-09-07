public class checkRecursive {
     public static boolean isTriggerExecuted = false;
     public static boolean runOnce()
     {
         if(isTriggerExecuted == false)
         {
             isTriggerExecuted = true;             
             return isTriggerExecuted;    
         }
         else
         {
             return false;
         }   
     }
}