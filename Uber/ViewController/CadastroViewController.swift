//
//  CadastroViewController.swift
//  Uber
//
//  Created by Jamilton  Damasceno
//  Copyright © Curso IOS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CadastroViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var nomeCompleto: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var tipoUsuario: UISwitch!
    
    @IBAction func cadastrarUsuario(_ sender: Any) {
        
        let retorno = self.validarCampos()
        if retorno == "" {
            
            //cadastrar usuario no Firebase
            let autenticacao = Auth.auth()
            
            if let emailR = self.email.text {
                if let nomeR = self.nomeCompleto.text {
                    if let senhaR = self.senha.text {
                        
                        autenticacao.createUser(withEmail: emailR, password: senhaR, completion: { (usuario, erro) in
                            
                            if erro == nil {
                                
                                //Valida se o usuário está logado
                                if usuario != nil {
                                    
                                    //configura database
                                    let database = Database.database().reference()
                                    let usuarios = database.child("usuarios")
                                    
                                    //Verifica tipo do usuário
                                    var tipo = ""
                                    if self.tipoUsuario.isOn {//Passageiro
                                        tipo = "passageiro"
                                    }else{//Motorista
                                        tipo = "motorista"
                                    }
                                    
                                    //Salva no banco de dados dados do usuário
                                    let dadosUsuario = [
                                        "email" : usuario?.email ,
                                        "nome" : nomeR ,
                                        "tipo" : tipo
                                    ]
                                    
                                    //salvar dados
                                    usuarios.child( (usuario?.uid)! ).setValue(dadosUsuario)
                                    
                                    /*
                                     Valida se o usuário está logado
                                     Caso o usuário esteja logado, será redirecionado
                                     automaticamente de acordo com o tipo de usuario
                                     com evento criado na ViewController
                                     */
                                    
                                    
                                }else{
                                   print("Erro ao autenticar o usuário!")
                                }
                                
                            }else{
                               print("Erro ao criar conta do usuário, tente novamente!")
                            }
                            
                        })
                        
                    }
                }
            }
            
            
        }else{
            print("O campo \(retorno) não foi preenchido!")
        }
        
    }
    
    func validarCampos() -> String {
        
        if (self.email.text?.isEmpty)! {
            return "E-mail"
        }else if (self.nomeCompleto.text?.isEmpty)! {
            return "Nome completo"
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
