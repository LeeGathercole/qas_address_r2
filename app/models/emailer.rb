class Emailer < ActionMailer::Base
  
   def contact(recipient, subject, message, sent_at = Time.now)
      subject       subject
      from          'info@kc.myhdnl.co.uk'
      recipients    recipient
      sent_on       sent_at
      body          message
   end

end
