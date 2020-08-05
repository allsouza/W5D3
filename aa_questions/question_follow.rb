require_relative 'questions_db_connect'
require_relative 'user'
require_relative 'question'

class QuestionFollow
  def self.followers_for_question_id(question_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows JOIN users ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.user_id
      FROM
        question_follows JOIN questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
    SELECT
        questions.*
    FROM
        question_follows
        JOIN questions ON
        questions.id = question_follows.question_id
    GROUP BY
        question_follows.question_id
    ORDER BY
        COUNT(question_follows.user_id) DESC
    LIMIT
        ?
    SQL
    questions.map { |question| Question.new(question) }
  end

end