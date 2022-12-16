require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize (name:, breed:, id: nil)
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(array)
        name = array[1]
        breed = array[2]
        dog_id = array[0]

        new_dog = self.new(name: name, breed: breed)
        new_dog.id = dog_id

        new_dog
    end

    def self.all
        DB[:conn].execute("SELECT * FROM dogs").map do |dog|
            Dog.new_from_db(dog)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |dog|
            Dog.new_from_db(dog)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |dog|
        Dog.new_from_db(dog)
    end.first
    end

end
