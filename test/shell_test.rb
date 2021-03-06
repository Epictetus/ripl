require File.join(File.dirname(__FILE__), 'test_helper')

describe "Shell" do
  before { reset_ripl }

  def shell(options={})
    Ripl.shell(options)
  end

  describe "#loop" do
    before { mock(shell).before_loop }
    it "exits with exit" do
      mock(shell).get_input { 'exit' }
      dont_allow(shell).eval_input
      shell.loop
    end

    it "exits with Control-D" do
      mock(shell).get_input { nil }
      dont_allow(shell).eval_input
      shell.loop
    end
  end

  describe "#prompt" do
    it "as a string" do
      shell(:prompt=>'> ').prompt.should == '> '
    end

    it "as a lambda" do
      shell(:prompt=>lambda { "#{10 + 10}> " }).prompt.should == '20> '
    end
  end

  describe "#eval_input" do
    before { @line = shell.line; shell.eval_input("10 ** 2") }

    describe "normally" do
      it "sets result" do
        shell.result.should == 100
      end

      it "sets _" do
        shell.eval_input('_')
        shell.result.should == 100
      end

      it "increments line" do
        shell.line.should == @line + 1
      end
    end

    describe "with error" do
      before {
        @line = shell.line
        @stderr = capture_stderr { shell.eval_input('{') }
      }

      it "prints it" do
        @stderr.should =~ /^SyntaxError: compile error/
      end

      it "sets @error_raised" do
        shell.instance_variable_get("@error_raised").should == true
      end

      it "increments line" do
        shell.line.should == @line + 1
      end
    end
  end
end
