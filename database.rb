MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'bentlettuce'

class User
    include MongoMapper::Document
    key :_id,           String    # username as id
    key :fullname,      String
    key :password,      String
    key :email,         String
    key :timestamp,     String
    key :fav_mp3s,      Array
    key :blogs,         Array
end

class Blog
    include MongoMapper::Document
    key :name,          String
    key :url,           String
    key :date,          Date
    key :last_file,     String
end

class Mp3File
    include MongoMapper::Document
    key :artist,        String
    key :title,         String
    key :file_name,     String
    key :url,           String
    key :date,          Date

    validates_uniqueness_of :url
end
