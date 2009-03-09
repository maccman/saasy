pdf.font.size = 11

# Shortcut
sa = @subscription_address

pdf.float([pdf.bounds.right - 100, pdf.bounds.top - 30]) do
  pdf.text AppConfig.app_name
  pdf.text "Your Street"
  pdf.text "Your City"
  pdf.text "Your Postcode"
  pdf.move_down(10)
  pdf.text "03939 2371 2828"
  pdf.text "info@example.com"
end

pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 30], :width => 430) do
  pdf.text "STATEMENT / TAX INVOICE", :size => 24
  
  pdf.move_down(30)
  
  pdf.float([pdf.bounds.right - 100, pdf.cursor], :width => 100) do    
    pdf.text "Invoice Date", :style => :bold
    pdf.text @transaction.created_at.to_s(:date)
    
    pdf.move_down(10)

    pdf.text "Invoice number", :style => :bold
    pdf.text "INV-#{@subscription.id}-#{@transaction.id}"
  end
  
  pdf.float([pdf.bounds.left, pdf.cursor]) do
    pdf.text "To:"
  end
  
  pdf.bounding_box([pdf.bounds.left + 20, pdf.cursor], :width => 260) do
    pdf.text sa.invoice_to
    pdf.text sa.street.split("\n").join(', ')
    pdf.text sa.city
    pdf.text sa.region
    pdf.text sa.postcode
    pdf.text sa.country
  end
  
  pdf.move_down(30)
  
  pdf.bounding_box([pdf.bounds.left, pdf.cursor], :width => pdf.bounds.width) do
    pdf.text "Current Invoice", :style => :bold, :size => 18
    
    pdf.move_down(5)
    pdf.stroke_horizontal_line pdf.bounds.left, pdf.bounds.right
    pdf.move_down(5)
    
    pdf.text  "#{sa.invoice_to} Subscription " \
              "from #{@transaction.meta[:from].to_s(:date)} to #{@transaction.meta[:to].to_s(:date)}"
    
    pdf.move_down(10)
    pdf.stroke_horizontal_line pdf.bounds.left, pdf.bounds.right
    pdf.move_down(5)
    
    pdf.bounding_box([pdf.bounds.right - 220, pdf.cursor], :width => 220) do
      pdf.float([pdf.bounds.left, pdf.cursor], :width => 184) do
        pdf.text "SUBTOTAL", :align => :right
        pdf.text "CURRENT INVOICE TOTAL", :style => :bold, :align => :right
      end
      pdf.bounding_box([pdf.bounds.right - 50, pdf.cursor], :width => 50) do
        pdf.text @transaction.money.format, :align => :right
        pdf.text @transaction.money.format, :style => :bold, :align => :right
      end
    end
    
    pdf.bounding_box([pdf.bounds.left, pdf.cursor], :width => pdf.bounds.width) do
      pdf.move_down(20)
      pdf.stroke_horizontal_line pdf.bounds.left, pdf.bounds.right
    
      pdf.float([pdf.bounds.right - 210, pdf.cursor], :width => 210) do
        pdf.text "AMOUNT DUE", :style => :bold, :size => 20, :align => :left        
      end
      pdf.bounding_box([pdf.bounds.right - 70, pdf.cursor], :width => 70) do
        pdf.text @transaction.money.format, :style => :bold, :size => 20, :align => :right
      end
      

      pdf.move_down(35)

      pdf.text "Automatic debit - no action required", :style => :bold, :size => 15
      pdf.text "The amount due will automatically be debited from your credit card on the #{@transaction.meta[:to].to_s(:date)}."
  
      pdf.move_down(20)
  
      pdf.text "Outstanding invoices charged per invoice", :style => :bold, :size => 15
      pdf.text "Payment for the current and outstanding invoices will be autoamtically charged against your " \
               "account and appear as separate transactions on your bank/credit card statement."
    end
  end
end