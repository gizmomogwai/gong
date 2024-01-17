["macos", "linux", "chrome"].each do |target|
  desc "Build #{target}"
  task "build-#{target}" do
    sh "flutter build #{target} --dart-define=name=#{`git describe --always --dirty`.strip} --release"
  end
  desc "Run #{target}"
  task "run-#{target}" do
    sh "flutter run --device-id=#{target} --dart-define=name=#{`git describe --always --dirty`.strip}"
  end
end

desc "Deploy web"
task "deploy-web" => ["build-web"] do
 sh "netlify deploy --prod --site=yogagong --dir=build/web"
end

desc "Format"
task :format do
  sh "dart format --summary=line --show=all ."
end