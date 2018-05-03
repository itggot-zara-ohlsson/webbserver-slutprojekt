class App < Sinatra::Base

	enable :sessions

	get('/') do 
		db = SQLite3::Database.new("db/slutprojekt.db")
		post = db.execute("SELECT * FROM post")
		slim(:index, locals:{post:post})
	end

	get('/login') do
		session[:login] = false
		session[:user_id] = nil
		slim(:login)
	end

	get('/register')do 
		slim(:register)
	end

	get('/home') do 
		db = SQLite3::Database.new("db/slutprojekt.db")
		if session[:login] == true
			post = db.execute("SELECT * FROM post")
			slim(:home, locals:{post:post})
		else
			redirect("/")
		end
	end

	get('/create_post') do
		slim(:create_post)
	end


	post('/login') do
		db = SQLite3::Database.new("db/slutprojekt.db")
		username = params["username"]
		password = params["password"]
		user = db.execute("SELECT * FROM users WHERE username = ?", [username])[0]
		session[:login] = false
		
		if BCrypt::Password.new(user[2]) == password
			session[:login] = true
			session[:user_id] = user[0]
			redirect('/home')
		end
		redirect('/')
	end

	post('/register') do
		db = SQLite3::Database.new("db/slutprojekt.db")
		username = params["username"]
		password = params["password"]
		password_digest = BCrypt::Password.create(password)
		db.execute("INSERT INTO users(username,password) VALUES(?,?)", [username,password_digest])
		redirect('/')
	end

	post('/home') do 
		db = SQLite3::Database.new("db/slutprojekt.db")
		content = params["content"]
		db.execute("INSERT INTO post(content) VALUES(?)", [content])
		redirect('/home')
	end

	post('/favorit/:post_id') do
		db = SQLite3::Database.new("db/slutprojekt.db")
		user_id = session[:user_id]
		friend_id = params["post_id"]
		db.execute("INSERT INTO favorit VALUES(?, ?)", [user_id, friend_id])
		redirect back
	end

	def numer_favorits (post_id)
		db = SQLite3::Database.new("db/slutprojekt.db")
		posts = db.execute("SELECT * FROM favorit WHERE friend_id=?", [post_id])
		posts.length
	end

end           
