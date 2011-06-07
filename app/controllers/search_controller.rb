class SearchController < ApplicationController
	# GET /searches
	# GET /searches.xml
	def index
		query_params = QueryFormat.catalog_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			@results = solr.search(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue RSolr::Error::Http => e
			render_error(e.to_s, :internal_server_error)
		end
	end

	# GET /searches/totals
	# GET /searches/totals.xml
	def totals
		is_test = Rails.env == 'test'
		@totals = Solr.get_totals(is_test)
#		results = [ { :name => 'NINES', :total_docs => 400, :total_archives => 12}, { :name => '18thConnect', :total_docs => 800, :total_archives => 24 } ]

		respond_to do |format|
			format.html # index.html.erb
			format.xml  # index.xml.builder
		end
	end

	# GET /searches/autocomplete
	# GET /searches/autocomplete.xml
	def autocomplete
		query_params = QueryFormat.autocomplete_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			max = query['max'].to_i
			query.delete('max')
			words = solr.auto_complete(query)
			words.sort! { |a,b| b[:count] <=> a[:count] }
			words = words[0..(max-1)]
			@results = words.map { |word|
				{ :item => word[:name], :occurrences => word[:count] }
			}

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue RSolr::Error::Http => e
			render_error(e.to_s, :internal_server_error)
		end
	end

	# GET /searches/names
	# GET /searches/names.xml
	def names
		query_params = QueryFormat.names_format()
		begin
			QueryFormat.transform_raw_parameters(params)
			query = QueryFormat.create_solr_query(query_params, params)
			is_test = Rails.env == 'test'
			solr = Solr.factory_create(is_test)
			@results = solr.names(query)

			respond_to do |format|
				format.html # index.html.erb
				format.xml
			end
		rescue ArgumentError => e
			render_error(e.to_s)
		rescue RSolr::Error::Http => e
			render_error(e.to_s, :internal_server_error)
		end
	end

	# GET /searches/details
	# GET /searches/details.xml
	def details
		uri = params[:uri]

		# TODO: Really make the call to get the document by uri here
#		@search = Search.find(params[:id])
		@id = uri
		results = { 'role_AUT' => [], 'role_EDT' => [], 'role_PBL' => [] }

		respond_to do |format|
			format.html # show.html.erb
			format.xml
		end
	end

end
