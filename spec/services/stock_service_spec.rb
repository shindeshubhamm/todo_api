require 'rails_helper'

RSpec.describe StockService do
  let(:service) { described_class.new }

  describe '#get_stocks' do
    context 'when the API call is successful' do
      it 'returns stock data for the given page and limit' do
        VCR.use_cassette('stocks_api/successful_request') do
          response = service.get_stocks(page: 1, limit: 2)

          expect(response).to be_a(Hash)
          expect(response['success']).to eq(true)
          expect(response['data']).to be_a(Hash)
          expect(response['data']['data']).to be_an(Array)
          expect(response['data']['data'].size).to eq(2)
          expect(response['data']['data'].first).to have_key('Name')
        end
      end
    end

    context 'when the API call fails' do
      it 'returns nil when the API returns an error' do
        # webmock
        stub_request(:get, "https://api.freeapi.app/api/v1/public/stocks")
          .with(query: { page: 99999, limit: 2 })
          .to_return(status: 404)

        response = service.get_stocks(page: 99999, limit: 2)
        expect(response).to be_nil
      end

      it 'handles network errors gracefully' do
        stub_request(:get, "https://api.freeapi.app/api/v1/public/stocks")
          .with(query: { page: 1, limit: 2 })
          .to_raise(HTTP::Error)

        response = service.get_stocks(page: 1, limit: 2)
        expect(response).to be_nil
      end
    end
  end
end
