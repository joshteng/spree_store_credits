Spree Store Credits
===================

[![Build
Status](https://secure.travis-ci.org/spree/spree_store_credits.png)](http://travis-ci.org/spree/spree_store_credits)


This Spree extension allows admins to issue arbitrary amounts of store credit to users.

Users can redeem store credit during checkout, as part or full payment for an order.

Also extends My Account page to display outstanding credit balance, and orders that used store credit.

Installation
============

1. Add the following to your applications Gemfile

    gem 'spree_store_credits'

2. Run bundler

    bundle install

3. Copy and execute migrations:

    rails g spree_store_credits:install



To Allow The Purchase Of Store Credit
============

1. Log in as admin, add store credits as a regular product with the SKU "credits" !IMPORTANT! All variants of store credit should have the SKU "credits" too.
2. Make sure that this site requires to be logged in to checkout (config.allow_guest_checkout should be set to false in spree initializer)

This extension will automatically add store credit on successful payment if it detects any "credits" in the order. It will add store credits to the buyer based on the price of the store credit and the quantity in the order. So no extra work is needed when adding a store credit as a product.

How much store credit is added to user's account?
product price x quantity = store credit to be added