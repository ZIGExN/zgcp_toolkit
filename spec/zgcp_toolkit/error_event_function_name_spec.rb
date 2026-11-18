RSpec.describe ZgcpToolkit::ErrorEventFunctionName do
  def event_for(backtrace)
    error = StandardError.new('boom')
    error.set_backtrace(backtrace)
    Google::Cloud::ErrorReporting::ErrorEvent.from_exception(error)
  end

  it 'keeps the function name of the Ruby <= 3.3 backtrace format' do
    event = event_for(["/app/models/car.rb:12:in `price'", "/app/a.rb:1:in `run'"])

    expect(event.function_name).to eq('price')
    expect(event.file_path).to eq('/app/models/car.rb')
    expect(event.line_number).to eq(12)
  end

  it 'reads the function name of the Ruby >= 3.4 backtrace format' do
    event = event_for(["/app/models/car.rb:12:in 'Car#price'", "/app/a.rb:1:in 'Object#run'"])

    expect(event.function_name).to eq('Car#price')
    expect(event.file_path).to eq('/app/models/car.rb')
    expect(event.line_number).to eq(12)
  end

  it 'reads a namespaced class, a class method and a block label' do
    expect(event_for(["/a.rb:3:in 'Master::Car.find'"]).function_name).to eq('Master::Car.find')
    expect(event_for(["/a.rb:3:in 'block in Car#price'"]).function_name).to eq('block in Car#price')
    expect(event_for(["/a.rb:3:in '<main>'"]).function_name).to eq('<main>')
  end

  it 'leaves the function name empty when there is no usable backtrace' do
    expect(event_for(nil).function_name).to be_nil
    expect(event_for([]).function_name).to be_nil
    expect(event_for(['no backtrace format']).function_name).to be_nil
  end

  it 'keeps the message with the whole backtrace' do
    event = event_for(["/a.rb:1:in 'A#m'", "/b.rb:2:in 'B#n'"])

    expect(event.message).to eq("StandardError: boom\n\t/a.rb:1:in 'A#m'\n\t/b.rb:2:in 'B#n'")
  end
end
