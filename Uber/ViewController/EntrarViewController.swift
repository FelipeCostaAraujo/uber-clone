//
//  EntrarViewController.swift
//  Uber
//
//  Created by Jamilton  Damasceno
//  Copyright © Curso IOS. All rights reserved.
//

import UIKit
import FirebaseAuth

class EntrarViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    
    @IBAction func entrar(_ sender: Any) {
        
        let retorno = self.validarCampos()
        if retorno == "" {
            
            //Faz autenticacao do usuario (Login)
            let autenticacao = Auth.auth()
            
            if let emailR = self.email.text {
                if let senhaR = self.senha.text {
                    
                    autenticacao.signIn(withEmail: emailR, password: senhaR, completion: { (usuario, erro) in
                        
                        if erro == nil {
                            
                            /*
                             Valida se o usuário está logado
                             Caso o usuário esteja logado, será redirecionado
                             automaticamente de acordo com o tipo de usuario
                             com evento criado na ViewController
                             */
                            if usuario == nil {
                               print("Erro ao logar usuario!")
                            }
                            
                        }else{
                            print("Erro ao autenticar usuário, tente novamente!")
                        }
                        
                    })
                        
                }
            }
            
            
            
            
        }else{
           print("O campo \(retorno) não foi preenchido!")
        }
        
    }
    
    func validarCampos() -> String {
        
        if (self.email.text?.isEmpty)! {
            return "E-mail"
        }else if (self.senha.text?.isEmpty)! {
            return "Senha"
        }
        
        return ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}
