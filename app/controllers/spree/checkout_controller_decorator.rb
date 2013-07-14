module Spree
  CheckoutController.class_eval do
    before_filter :remove_payments_attributes_if_total_is_zero

    alias_method :orig_update, :update
    alias_method :orig_paypal_finish, :paypal_finish

    # ##JOSH
    # # Updates the order and advances to the next state (when possible.)
    # def update
    #   if @order.update_attributes(object_params)
    #     fire_event('spree.checkout.update')
    #     return if after_update_attributes

    #     unless @order.next
    #       flash[:error] = @order.errors[:base].join("\n")
    #       redirect_to checkout_state_path(@order.state) and return
    #     end

    #     if @order.completed?
    #       ##I ADDED
    #       @order.line_items.each do |line_item|
    #         variant = line_item.variant
    #         if variant.sku.downcase == 'credits'
    #           preferred_amount = variant.price * line_item.quantity
    #           @order.user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount,  :reason => "Bought store credits")
    #         end
    #       end
    #       ##I ADDED

    #       session[:order_id] = nil
    #       flash.notice = Spree.t(:order_processed_successfully)
    #       flash[:commerce_tracking] = "nothing special"
    #       redirect_to completion_route
    #     else
    #       redirect_to checkout_state_path(@order.state)
    #     end
    #   else
    #     render :edit
    #   end
    # end
    # ##JOSH


    ##JOSH: A better version of update.. TO BE TESTED.. IF NOT REVERT TO OLD ONE ON TOP.. TEST this after I add ipay88
    ##JOSH
    def update
      if @order.completed?
        process_and_add_store_credit(@order)
      end

      return orig_update
    end
    ##JOSH

    ##JOSH: To make it work with spree_paypal_express gem
    ##JOSH
    def paypal_finish
      if @order.state = "confirm"
        process_and_add_store_credit(@order)
      end

      return orig_paypal_finish
    end
    ##JOSH

    private

    def process_and_add_store_credit(order)
      order.line_items.each do |line_item|
        variant = line_item.variant
        if variant.sku.downcase == 'credits'
          preferred_amount = variant.price * line_item.quantity
          order.user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount,  :reason => "Bought store credits")
        end
      end
    end

    def remove_payments_attributes_if_total_is_zero
      load_order

      return unless params[:order] && params[:order][:store_credit_amount]
      store_credit_amount = [BigDecimal.new(params[:order][:store_credit_amount]), spree_current_user.store_credits_total].min
      if store_credit_amount >= (current_order.total + @order.store_credit_amount)
        params[:order].delete(:source_attributes)
        params.delete(:payment_source)
        params[:order].delete(:payments_attributes)
      end
    end
  end
end
