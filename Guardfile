# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :cane do
  watch(/.*\.rb/)
end

guard 'minitest' do
  # with Minitest::Unit
  watch(%r|^test/(.*)_test.rb|)

  # with Minitest::Spec
  # watch(%r|^spec/(.*)_spec\.rb|)
  # watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  # watch(%r|^spec/spec_helper\.rb|)    { "spec" }
end
