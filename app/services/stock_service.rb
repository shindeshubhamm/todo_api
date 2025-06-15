class StockService
  BASE_URL = "https://api.freeapi.app/api/v1/public/stocks".freeze

  def get_stocks(page: 1, limit: 10)
    response = HTTP.get(BASE_URL, params: {
      page: page,
      limit: limit
    })

    return nil unless response.status.success?

    JSON.parse(response.body.to_s)
  rescue HTTP::Error => e
    Rails.logger.error("Stock API error: #{e.message}")
    nil
  end
end
