# shellcheck disable=SC2148
if [[ -f "$HOME/.local/share/graalvm/bin/java" ]] && [[ ! "$PATH" =~ $HOME/.local/share/graalvm/bin: ]]; then
  export PATH="$HOME/.local/share/graalvm/bin:$PATH"
  export GRAALVM_HOME="$HOME/.local/share/graalvm"
  export JAVA_HOME="$HOME/.local/share/graalvm"
fi

if [[ -f "$HOME/.local/share/java/bin/java" ]] && [[ ! "$PATH" =~ $HOME/.local/share/java/bin: ]]; then
  export PATH="$HOME/.local/share/java/bin:$PATH"
  export JAVA_HOME="$HOME/.local/share/java"
fi

if [[ -f "$HOME/.local/share/maven/bin/mvn" ]] && [[ ! "$PATH" =~ $HOME/.local/share/maven/bin: ]]; then
  export PATH="$HOME/.local/share/maven/bin:$PATH"
  export M2_HOME="$HOME/.local/share/maven"
  export MAVEN_HOME="${M2_HOME}"
fi

if [[ -f "$HOME/.local/share/gradle/bin/gradle" ]] && [[ ! "$PATH" =~ $HOME/.local/share/gradle/bin: ]]; then
  export PATH="$HOME/.local/share/gradle/bin:$PATH"
  export GRADLE_HOME="$HOME/.local/share/gradle"
fi

if [[ -f "$HOME/.local/share/groovy/bin/groovy" ]] && [[ ! "$PATH" =~ $HOME/.local/share/groovy/bin: ]]; then
  export PATH="$HOME/.local/share/groovy/bin:$PATH"
  export GROOVY_HOME="$HOME/.local/share/groovy"
fi

if [[ -f "$HOME/.local/share/kotlinc/bin/kotlinc" ]] && [[ ! "$PATH" =~ $HOME/.local/share/kotlinc/bin: ]]; then
  export PATH="$HOME/.local/share/kotlinc/bin:$PATH"
fi
