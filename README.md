# ActiveRecord Lite

This project was built as a learning exercise to gain a greater understanding of the inner workings of ActiveRecord. It implements several core features of ActiveRecord from Rails 3.2 in SQL using SQLite3:

- Model Objects
    - attributes and mass-assignment
- Associations
    - ```has_many```
    - ```belongs_to```
    - ```has_one_through```
- Queries
    - ```Record.find(params[:id])```
    - ```Record.where( ... )```
    - ```Record.all```
    - ```Record.save``` (i.e. ```create``` and ```update```)

**See Also:**

This project is the precursor of [rails-lite](http://github.com/wvandaal/rails-lite), a similar project I built to explore the inner workings of Rails 3.2.