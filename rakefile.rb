["macos", "linux", "web"].each do |target|
  desc "Build #{target}"
  task "build-#{target}" do
    sh "flutter build #{target} --dart-define=name=#{`git describe --always --dirty`.strip} --release"
  end
end

desc "Deploy web"
task "deploy-web" => ["build-web"] do
 sh "netlify deploy --prod --site=yogagong --dir=build/web"
end
