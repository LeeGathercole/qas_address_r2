class FormattedAddress

  attr_accessor :propertyno
  attr_accessor :streetname
  attr_accessor :town
  attr_accessor :postcode
  attr_accessor :organisation
  attr_accessor :addressline3

# Converts a QAS Address into and Intraship Address
# Check first to see if there is an organisation as this has a different set
# of heuristics
# It means the remainder of the address is on line 2, but there could be a mix
# of street name and property address. Assumption is for the street name to always
# be in the last entry and the number in the first one, this in most cases is the
# same element. Data is populated and removed from the array
#
# If it's a residential address, the property no is checked in line 1 and line 2
# extracting when found.
# If we can't find a property no then we have to assume we have a house name in
# addressline 1, depending on whether there is more than one entry on line 1 dictates
# whether this is assumed to be the street name or not.
# If it's a flat then the street name is on the second line

  def to_intraddress(q)
    #Split Address Line 1 and 2 into arrays
    addressline1Arr = q.addressline1 == nil ? [""] : q.addressline1.split(",")
    addressline2Arr = q.addressline2 == nil ? [""] : q.addressline2.split(",")

    
    #check for organisation first
    if q.isorganisation then      
      self.organisation = addressline1Arr[0]      
      addressline1Arr.delete_at(0)
      self.streetname = extract_street_name(addressline2Arr.last)            
      self.propertyno = extract_prop_no(addressline2Arr.first)    
      
      addressline2Arr[addressline2Arr.length - 1] = addressline2Arr.last.delete(self.streetname).strip
      addressline2Arr[0] = addressline2Arr.first.delete(self.propertyno).strip

      addressline2Arr.delete_if { |x| x.length == 0}

    else
      if is_propno_present(addressline1Arr[0]) then      
        extract_prop_no_street(addressline1Arr[0])        
        addressline1Arr.delete_at(0)
      elsif is_propno_present(addressline2Arr[0]) then        
        extract_prop_no_street(addressline2Arr[0])        
        addressline2Arr.delete_at(0)
      else
        if addressline1Arr[0].match(/Flat/) then
          self.streetname = addressline2Arr[0]
          addressline2Arr.delete_at(0)
        else
          if addressline1Arr.length > 1 then
            self.streetname = addressline1Arr[1]
            addressline1Arr.delete_at(1)
          else
            self.streetname = addressline2Arr[0]
            addressline2Arr.delete_at(0)
          end
        end
      end
    end
    #Address Line 3 Sweep up, gather all the remaining data left and
    #put into address line 3
    self.addressline3 = addressline1Arr.concat(addressline2Arr).join(",")
    self.postcode = q.postcode
    self.town = q.town
 
  end

  def is_propno_present (addressline)    
    propcheck =  addressline.index(" ") == nil ?  "" : addressline.slice(0, addressline.index(" "))
    return propcheck.match(/\d+\D?\Z/) ? true : false
  end


  def extract_prop_no(addressline)
    if is_propno_present (addressline)
      return addressline.slice(0, addressline.index(" "))
    else
      return ""
    end
  end

  def extract_street_name(addressline)
    if is_propno_present (addressline) then
      return addressline.slice(addressline.index(" "), addressline.length - addressline.index(" "))
    else
      #ok so looks like we haven't got a property no, so assume a street
      return addressline
    end

  end


  def extract_prop_no_street (addressline)
    #Property No and Street name will always be the first
    #element,just need to decide if there's a property no or not
    if is_propno_present (addressline)
      #we have a number so lets populate it and the street
      self.propertyno = addressline.slice(0, addressline.index(" "))
      #also take out the remainder and put as the street
      self.streetname = addressline.slice(addressline.index(" "), addressline.length - addressline.index(" "))
    else
      #ok so looks like we haven't got a property no, so assume a street
      self.streetname = addressline
    end
  end

  
  def initialize(q)
    self.to_intraddress(q)
  end

end
