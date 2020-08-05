require_relative 'questions_db_connect'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'

class User
    attr_accessor :id, :fname, :lname
    def self.all
      data = QuestionDBConnection.instance.execute("SELECT * FROM users")
      data.map { |datum| User.new(datum) }
    end

    def self.find_by_name(name)
        f_name, l_name = name.split.first, name.split.last
        user = QuestionDBConnection.instance.execute(<<-SQL, f_name, l_name) 
            SELECT
              * 
            FROM
              users
            WHERE
              fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def create
      raise "#{self} already exists in database" if self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionDBConnection.instance.last_insert_row_id
    end

    def update
      raise "#{self} does not exist in database" unless self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end

    def save
      self.id ? self.update : self.create
    end

    def authored_questions
      Question.find_by_author_id(self.id)
    end

    def authored_replies
      Reply.find_by_user_id(self.id)
    end

    def followed_questions
      QuestionFollow.followed_questions_for_user_id(self.id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)    
    end

    def average_karma
      results = QuestionDBConnection.instance.execute(<<-SQL, self.id)
        SELECT
          COUNT(DISTINCT(questions.id)) AS questions, COUNT(questions.id) AS likes
        FROM
          questions
          LEFT OUTER JOIN question_likes ON questions.id = question_likes.question_id
        WHERE
          questions.user_id = ?
      SQL
      results.first.values[1] / results.first.values[0].to_f
    end
end