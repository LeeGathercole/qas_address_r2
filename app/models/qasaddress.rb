class QASAddress 
  attr_accessor :addressline1
  attr_accessor :addressline2
  attr_accessor :town
  attr_accessor :postcode
  attr_accessor :isorganisation


    def to_qasAddress(qasHash)
    #Cycle through the addresslines and take keys out as they are processed
    #assumption that they are received in order
    qasHash.each do |addLine|
      case addLine[:label]
        when nil
          if self.addressline1  == nil then
            self.addressline1 = addLine[:line]
          else
            self.addressline2 = addLine[:line]
          end
        when 'Town' then self.town = addLine[:line]
        when 'Postcode' then self.postcode = addLine[:line]
        when 'PAF Delivery Point Type'
          self.isorganisation = addLine[:line] == 'R'? false : true
        end
      end
    end


    #def initialize(hash)
    #hash.each do |k,v|
    #  self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
    #  self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
    #  self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    #end
  

  def initialize(hash)
    self.to_qasAddress(hash)
  end

end
