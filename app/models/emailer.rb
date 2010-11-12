class Emailer < ActionMailer::Base
  
   def contact(recipient, subject, message, sent_at = Time.now)
      subject       subject
      from          "Test <test@testme.com>"
      recipients    recipient
      sent_on       sent_at
      body          message
   end

end
