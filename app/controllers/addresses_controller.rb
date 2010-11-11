require 'savon'
require 'qasaddress.rb'
require 'formattedaddress.rb'



class AddressesController < ApplicationController
  
  #require 'QAS.rb'
  # GET /addresses
  # GET /addresses.xml
  def index    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @address }
    end
  end

  # GET /addresses/1
  # GET /addresses/1.xml
  def show        
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @address }
    end
  end

  # GET /addresses/:postcode/search
  def search
    client = Savon::Client.new "#{APP_CONFIG[:qas_address]}"
    
    response = client.do_search  do |soap|
      soap.input = "QASearch"
      soap.body = {
        "wsdl:Country" => "GBR", "wsdl:Engine" => "Singleline",
        "wsdl:Layout" => "HDNGBR", "wsdl:Search" => params[:postcode],
        :attributes! => {"wsdl:Engine" => {'Flatten'=>'true', 'Intensity' => 'Close',
            'PromptSet' => '', 'Threshold' => '100', 'Timeout' => '5'}}
        }
    end
   
    qapickList = response.to_hash[:qa_search_result][:qa_picklist]
    
    case qapickList[:total].to_i

    when 0
      flash[:notice] = "No Postcodes Matching"
      redirect_to "/addresses"
    when 1
      #Only 1 match so get more details
      #Need to extract the moniker and redirect to the show screen      
      redirect_to "/addresses/" +  qapickList[:picklist_entry][:moniker]
    else
      @pickList = qapickList[:picklist_entry]
    end
              
  end

  # GET /addresses/:moniker/get
  def getaddress

    client = Savon::Client.new "#{APP_CONFIG[:qas_address]}"

    response = client.do_get_address  do |soap|
      soap.input = "QAGetAddress"
      soap.body = {
        "Moniker" => params[:moniker], "Layout" => "HDNGBR"
         }
    end

    @qasaddress = QASAddress.new(response.to_hash[:address][:qa_address][:address_line])

    @formattedaddress = FormattedAddress.new(@qasaddress)

    #@qasaddress = QASAddress.new("9 Sutcliffe Wood Lane", "", "Halifax", "HX3 8PR")
    respond_to do |format|
      format.html # getaddress.html.erb
      format.xml  { render :xml => @address }
    end
  end


end
