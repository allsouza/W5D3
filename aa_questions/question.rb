require_relative 'questions_db_connect'

class Question
    attr_accessor :id, :title, :body, :user_id

    def self.all
      data = QuestionDBConnection.instance.execute("SELECT * FROM questions")
      data.map { |datum| Question.new(datum) }
    end

    def self.find_by_id(id)
      question = QuestionDBConnection.instance.execute(<<-SQL, id)
        SELECT
          * 
        FROM
          questions
        WHERE
          id = ?
        SQL
      return nil unless question.length > 0
      Question.new(question.first)
    end

    def self.find_by_author_id(user_id)
      questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
        SELECT
          * 
        FROM
          questions
        WHERE
          user_id = ?
        SQL
      return nil unless questions.length > 0
      questions.map { |question| Question.new(question) }
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def create
      raise "#{self} already exists in database" if self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.title, self.body, self.user_id)
        INSERT INTO
          questions (title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionDBConnection.instance.last_insert_row_id
    end

    def update
      raise "#{self} does not exist in database" unless self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.title, self.body, self.user_id, self.id)
        UPDATE
          questions
        SET
          title = ?, body = ?, user_id = ?
        WHERE
          id = ?
      SQL
    end

    def author
      author = QuestionDBConnection.instance.execute(<<-SQL, self.user_id)
        SELECT
          *
        FROM
          users
        WHERE
          users.id = ?
      SQL
      User.new(author.first)
    end

    def replies
      Reply.find_by_question_id(self.id)
    end
end