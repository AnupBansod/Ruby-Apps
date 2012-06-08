class CouponFirstPurchaseValue < CouponValue
  def eligible?(order, at = Time.zone.now )
    (starts_at <= at && expires_at >= at) && (order.user.try(:number_of_finished_orders_at, at) == 0) rescue false
  end
end

class CouponFirstPurchasePercent < CouponPercent
  def eligible?(order, at = Time.zone.now)
    (starts_at <= at && expires_at >= at) && (order.user.try(:number_of_finished_orders_at, at) == 0) rescue false
  end
end