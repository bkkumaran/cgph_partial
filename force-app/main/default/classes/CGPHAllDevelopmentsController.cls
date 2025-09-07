public class CGPHAllDevelopmentsController {
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapPurchaseDevelopmentsByCounty {get;set;}
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapRentalDevelopmentsByCounty {get;set;}
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapAllDevelopmentsByCounty {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapRentalDevelopmentsByMuni {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapPurchaseDevelopmentsByMuni {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapAllDevelopmentsByMuni {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapRentalDevelopmentsByAlpha {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapPurchaseDevelopmentsByAlpha {get;set;}
    public Map<String,Map<String,Map<String,String>>> mapAllDevelopmentsByAlpha {get;set;}
    public Map<String,Boolean> mapRentalIdx {get;set;}
    public Map<String,Boolean> mapPurchaseIdx {get;set;}
    public Map<String,Boolean> mapAllIdx {get;set;}
    public String defType {get;set;}
    public String defBy {get;set;}

    //method to show rental devlopments
    public CGPHAllDevelopmentsController(){
        	//param pass through
        	defType = System.currentPageReference().getParameters().get('typ');
        	defBy = System.currentPageReference().getParameters().get('by');

			mapPurchaseDevelopmentsByCounty = mapPurchaseDevelopmentsByCounty();
            mapRentalDevelopmentsByCounty = mapRentalDevelopmentsByCounty();
        	mapAllDevelopmentsByCounty = mapAllDevelopmentsByCounty();
        	mapPurchaseDevelopmentsByMuni = mapPurchaseDevelopmentsByMuni();
            mapRentalDevelopmentsByMuni = mapRentalDevelopmentsByMuni();
        	mapAllDevelopmentsByMuni = mapAllDevelopmentsByMuni();
        	mapPurchaseDevelopmentsByAlpha = mapPurchaseDevelopmentsByAlpha();
            mapRentalDevelopmentsByAlpha = mapRentalDevelopmentsByAlpha();
        	mapAllDevelopmentsByAlpha = mapAllDevelopmentsByAlpha();
	}
    
    
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapDevelopmentsByCounty(string PropertyType) {
        Map<String,Map<String,Map<String,Map<String,String>>>> mapAllCounties = new Map<String,Map<String,Map<String,Map<String,String>>>>();
        String devSOQL =	'SELECT Id, Municipality_Name__c, Municipality_Name__r.Id, Municipality_Name__r.County__c, ';
            devSOQL +=		'Municipality_Name__r.Municipality_Name_Calc__c, Name, ';
        	devSOQL +=		'HOMEtracker__Status__c ';
            devSOQL +=		'FROM HOMEtracker__Property__c ';
            devSOQL +=		'WHERE ';
        if (PropertyType != 'All') {
            devSOQL +=		'(Rental_or_Sale_Development__c = :PropertyType) AND ';
        }
        	devSOQL += 		'Development_address__c = null AND ';
        	devSOQL += 		'Devel_Visible_on_Website__c = TRUE AND ';
            devSOQL += 		'Municipality_Name__r.Muni_Visible_on_Website__c = TRUE ';
            devSOQL +=		'ORDER BY Municipality_Name__r.County__c, Municipality_Name__r.Municipality_Name_Calc__c, Name';
        
        Map<ID, HOMEtracker__Property__c> mapDevelopments = new Map<ID, HOMEtracker__Property__c>(
            (List<HOMEtracker__Property__c>)Database.query(devSOQL)
		);

        if(mapDevelopments != null && mapDevelopments.size() > 0) {
			for (HOMEtracker__Property__c property : mapDevelopments.values()) {
                Municipality__c pmuni = property.Municipality_Name__r;
                if ( !mapAllCounties.containsKey(pmuni.County__c)  ) {
                    mapAllCounties.put(pmuni.County__c, new Map<String,Map<String,Map<String,String>>>());
                }
                Map<String,Map<String,Map<String,String>>> county = mapAllCounties.get(pmuni.County__c);
                if ( !county.containsKey(pmuni.Municipality_Name_Calc__c) ) {
                    county.put(pmuni.Municipality_Name_Calc__c, new Map<String,Map<String,String>>());
                }
                Map<String,Map<String,String>> municipality = county.get(pmuni.Municipality_Name_Calc__c);
                Map<String,String> propertyMap = new Map<String,String>();
                propertyMap.put('id', property.Id);
                propertyMap.put('mid', property.Municipality_Name__r.Id);
                propertyMap.put('name', property.Name);
                propertyMap.put('not_admin', property.HOMEtracker__Status__c
                             				== 'Not administered directly by CGP&H' ? 'true' : 'false');
                Pattern notAN = Pattern.compile('[^a-zA-Z0-9]');
                Matcher rmatch = notAN.matcher(property.Name + property.Id);
                municipality.put(rmatch.replaceAll(''), propertyMap);
            }
    	}
        return mapAllCounties;
    }
    
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapPurchaseDevelopmentsByCounty() {
        return mapDevelopmentsByCounty('Sale');
    }
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapRentalDevelopmentsByCounty() {
        return mapDevelopmentsByCounty('Rental');
    }
    public Map<String,Map<String,Map<String,Map<String,String>>>> mapAllDevelopmentsByCounty() {
        return mapDevelopmentsByCounty('All');
    }

    public Map<String,Map<String,Map<String,String>>> mapDevelopmentsByMuni(string PropertyType) {
        Map<String,Map<String,Map<String,String>>> mapAllMuni = new Map<String,Map<String,Map<String,String>>>();
        String devSOQL =	'SELECT Id, Municipality_Name__c, Municipality_Name__r.Id, Municipality_Name__r.County__c, ';
            devSOQL +=		'Municipality_Name__r.Municipality_Name_Calc__c, Name, ';
            devSOQL +=		'HOMEtracker__Status__c ';
            devSOQL +=		'FROM HOMEtracker__Property__c ';
            devSOQL +=		'WHERE ';
        if (PropertyType != 'All') {
            devSOQL +=		'(Rental_or_Sale_Development__c = :PropertyType) AND ';
        }
            devSOQL +=		'Development_address__c = null AND ';
            devSOQL +=		'Devel_Visible_on_Website__c = TRUE AND ';
            devSOQL +=		'Municipality_Name__r.Muni_Visible_on_Website__c = TRUE ';
            devSOQL +=		'ORDER BY Municipality_Name__r.Municipality_Name_Calc__c, Name';
        
        Map<ID, HOMEtracker__Property__c> mapDevelopments = new Map<ID, HOMEtracker__Property__c>(
            (List<HOMEtracker__Property__c>)Database.query(devSOQL)
		);

        if(mapDevelopments != null && mapDevelopments.size() > 0) {
			for (HOMEtracker__Property__c property : mapDevelopments.values()) {
                Municipality__c pmuni = property.Municipality_Name__r;
                if ( !mapAllMuni.containsKey(pmuni.Municipality_Name_Calc__c)  ) {
                    mapAllMuni.put(pmuni.Municipality_Name_Calc__c, new Map<String,Map<String,String>>());
                }
                Map<String,Map<String,String>> municipality = mapAllMuni.get(pmuni.Municipality_Name_Calc__c);
                Map<String,String> propertyMap = new Map<String,String>();
                propertyMap.put('id', property.Id);
                propertyMap.put('mid', property.Municipality_Name__r.Id);
                propertyMap.put('name', property.Name);
                propertyMap.put('not_admin', property.HOMEtracker__Status__c
                             				== 'Not administered directly by CGP&H' ? 'true' : 'false');
                Pattern notAN = Pattern.compile('[^a-zA-Z0-9]');
                Matcher rmatch = notAN.matcher(property.Name + property.Id);
                municipality.put(rmatch.replaceAll(''), propertyMap);
            }
    	}
        return mapAllMuni;
    }
    
    public Map<String,Map<String,Map<String,String>>> mapPurchaseDevelopmentsByMuni() {
        return mapDevelopmentsByMuni('Sale');
    }
    public Map<String,Map<String,Map<String,String>>> mapRentalDevelopmentsByMuni() {
        return mapDevelopmentsByMuni('Rental');
    }
    public Map<String,Map<String,Map<String,String>>> mapAllDevelopmentsByMuni() {
        return mapDevelopmentsByMuni('All');
    }
    
    public Map<String,Map<String,Map<String,String>>> mapDevelopmentsByAlpha(string PropertyType) {
        Map<String,Map<String,Map<String,String>>> mapAllAlpha = new Map<String,Map<String,Map<String,String>>>();
        Map<String,Boolean> mapAlpha = new Map<String,Boolean>();
        
        String alphaList = '#ABCDEFGHIJKLMNOPOQRSTUVWXYZ';
        for (Integer c = 0; c < alphaList.length(); c++) {
            mapAlpha.put(alphaList.substring(c,c+1), false);
        }
        
        String devSOQL =	'SELECT Id, Municipality_Name__c, Municipality_Name__r.Id, Municipality_Name__r.County__c, ';
            devSOQL +=		'Municipality_Name__r.Municipality_Name_Calc__c, Name, ';
        	devSOQL +=		'HOMEtracker__Status__c ';
            devSOQL +=		'FROM HOMEtracker__Property__c ';
            devSOQL +=		'WHERE ';
        if (PropertyType != 'All') {
            devSOQL +=		'(Rental_or_Sale_Development__c = :PropertyType) AND ';
        }
            devSOQL += 		'Development_address__c = null AND ';
        	devSOQL += 		'Devel_Visible_on_Website__c = TRUE AND ';
        	devSOQL += 		'Municipality_Name__r.Muni_Visible_on_Website__c = TRUE ';
            devSOQL +=		'ORDER BY Municipality_Name__r.Municipality_Name_Calc__c, Name';
        
        Map<ID, HOMEtracker__Property__c> mapDevelopments = new Map<ID, HOMEtracker__Property__c>(
            (List<HOMEtracker__Property__c>)Database.query(devSOQL)
		);

        if(mapDevelopments != null && mapDevelopments.size() > 0) {
			for (HOMEtracker__Property__c property : mapDevelopments.values()) {
                String palpha = property.Name.substring(0,1).toUpperCase().replaceAll('[0-9]','#');
                mapAlpha.put(palpha, true);
                if ( !mapAllAlpha.containsKey(palpha)  ) {
                    mapAllAlpha.put(palpha, new Map<String,Map<String,String>>());
                }
                Map<String,Map<String,String>> alpha = mapAllAlpha.get(palpha);
                Map<String,String> propertyMap = new Map<String,String>();
                propertyMap.put('id', property.Id);
                propertyMap.put('mid', property.Municipality_Name__r.Id);
                propertyMap.put('name', property.Name);
                propertyMap.put('not_admin', property.HOMEtracker__Status__c
                             				== 'Not administered directly by CGP&H' ? 'true' : 'false');
                Pattern notAN = Pattern.compile('[^a-zA-Z0-9]');
                Matcher rmatch = notAN.matcher(property.Name + property.Id);
                alpha.put(rmatch.replaceAll(''), propertyMap);
            }
    	}

        switch on PropertyType {
            when 'Sale' {
                mapPurchaseIdx = mapAlpha;
            }
            when 'Rental' {
                mapRentalIdx = mapAlpha;
            }
            when 'All' {
                mapAllIdx = mapAlpha;
            }
        }

        return mapAllAlpha;
    }

    
    public Map<String,Map<String,Map<String,String>>> mapPurchaseDevelopmentsByAlpha() {
        return mapDevelopmentsByAlpha('Sale');
    }
    public Map<String,Map<String,Map<String,String>>> mapRentalDevelopmentsByAlpha() {
        return mapDevelopmentsByAlpha('Rental');
    }
    public Map<String,Map<String,Map<String,String>>> mapAllDevelopmentsByAlpha() {
        return mapDevelopmentsByAlpha('All');
    }

}