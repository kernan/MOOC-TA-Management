class TestResultsController < ApplicationController
  before_filter :require_teaching_assistant, :only => [:ta_index]
  before_filter :require_teaching_assistant, :only => [:new, :create]
  before_filter :only => [:index] {
    require_specific_user(
      if params[:teaching_assistant_id]
        User.find(params[:teaching_assistant_id])
      else
        TaTest.find(params[:ta_test_id]).course.professor
      end
    )
  }

  # GET /test_results
  # GET /test_results.json
  def index
    if params[:teaching_assistant_id]
      @teaching_assistant = TeachingAssistant.find(params[:teaching_assistant_id])
      session[:ta_index] = @teaching_assistant
      @test_results = TestResult.where(:teaching_assistant_id => @teaching_assistant)
    else
      session[:ta_index] = nil
      @ta_test = TaTest.find(params[:ta_test_id])
      @test_results = @ta_test.test_results.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @test_results }
    end
  end

  # GET /test_results/new
  # GET /test_results/new.json
  def new
    @ta_test = TaTest.find(params[:ta_test_id])
    @ta = TeachingAssistant.find(current_user.id)
    @test_result = @ta_test.test_results.new(:teaching_assistant => @ta)

    @qs_and_as = Array.new

    @ta_test.questions.each do |question|
      question_result = @test_result.question_results.build
      question_result.question = question
      @qs_and_as.push(question.content)
      question.answers.each do |answer|
        answer_result = question_result.answer_results.build
        answer_result.answer = answer
        @qs_and_as.push(answer.content)
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: [@ta_test, @test_result] }
    end
  end

  # POST /test_results
  # POST /test_results.json
  def create
    @ta_test = TaTest.find(params[:ta_test_id])
    @course = @ta_test.course
    @test_result = @ta_test.test_results.new(params[:test_result])

    @qs_and_as = Array.new
    @ta_test.questions.each do |question|
      @qs_and_as.push(question)
      question.answers.each do |answer|
        @qs_and_as.push(answer)
      end
    end
    @i = 0
    @test_result.question_results.each do |question_result|
      @correctness = true
      question_result.question = @qs_and_as[@i]
      @i = @i + 1
      question_result.answer_results.each do |answer_result|
        answer_result.answer = @qs_and_as[@i]
        @i = @i + 1
      end
    end
    
    @test_result.teaching_assistant = TeachingAssistant.find(current_user.id)

    respond_to do |format|
      if @test_result.save
        format.html { redirect_to @test_result, notice: 'Test was successfully taken.' }
        format.json { render json: @test_result, status: :created, location: @test_result }
      else
        format.html { redirect_to course_ta_tests_path(@course), notice: 'Test could not be taken.' }
        format.json { render json: @test_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @test_result = TestResult.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @test_result }
    end
  end

end
