require 'test_helper'

describe MoviesController do
    describe 'index' do
        it 'is a working route' do
            get movies_path
            must_respond_with :success
        end

        it 'returns json' do
            get movies_path
            response.header['Content-Type'].must_include 'json'
        end

        it 'returns an Array' do
            get movies_path

            body = JSON.parse(response.body)
            body.must_be_kind_of Array
        end

        it 'returns all of the movies' do
            get movies_path

            body = JSON.parse(response.body)
            body.length.must_equal Movie.count
        end

        it 'returns movies with exactly the required fields' do
            keys = %w(id release_date title)
            get movies_path

            body = JSON.parse(response.body)
            body.each do |movie|
                movie.keys.sort.must_equal keys
            end
        end
    end

    describe 'show' do
        it 'can get a movie' do
            get movie_path(movies(:one).title)
            must_respond_with :success
        end

        it 'returns movie with exactly the required fields' do
            keys = %w(available_inventory inventory overview release_date title)
            get movie_path(movies(:two).title)

            body = JSON.parse(response.body)
            body.keys.sort.must_equal keys
        end

        it 'returns 404 not found if movie does not exsist' do
            get movie_path('No movie has this bogus title say Queen Tofu the fluff')
            must_respond_with :not_found
        end
    end

    describe 'checkout' do
        it 'can checkout a movie' do
            test_customer = customers(:one)
            test_movie = movies(:one)

            movie_inventory = test_movie.available_inventory - 1
            customer_movies = test_customer.movies.length + 1

            post checkout_path(customer_id: test_customer.id, title: test_movie.title)
            must_respond_with :success

            test_movie.reload

            test_movie.available_inventory.must_equal movie_inventory
            test_customer.movies.count.must_equal customer_movies
        end
    end

    describe 'checkin' do
        it 'can checkin a movie' do
            test_customer = customers(:one)
            test_movie = movies(:one)

            movie_inventory = test_movie.available_inventory
            customer_movies = test_customer.movies.length

            post checkout_path(customer_id: test_customer.id, title: test_movie.title)
            test_movie.reload
            test_movie.available_inventory.wont_equal movie_inventory

            post checkin_path(customer_id: test_customer.id, title: test_movie.title)
            must_respond_with :success

            test_movie.reload

            test_movie.available_inventory.must_equal movie_inventory
            test_customer.movies.count.must_equal customer_movies
        end
    end
end
