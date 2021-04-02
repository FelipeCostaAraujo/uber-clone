//
//  MotoristaTableViewController.swift
//  Uber
//
//  Created by Jamilton  Damasceno
//  Copyright © Curso IOS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class MotoristaTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var listaRequisicoes : [DataSnapshot] = []
    var gerenciadorLocalizacao = CLLocationManager()
    var localMotorista = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configurar localizacao do motorista
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
        //configura banco de dados
        let database = Database.database().reference()
        let requisicoes = database.child("requisicoes")
        
        //Recuperar requisicoes
        requisicoes.observe(.value) { (snapshot) in
            
            self.listaRequisicoes = []
            
            if snapshot.value != nil {
                for filho in snapshot.children {
                    self.listaRequisicoes.append( filho as! DataSnapshot )
                }
            }
            
            self.tableView.reloadData()
        }

        //Limpa requisicao caso usuário cancele
        requisicoes.observe(.childRemoved) { (snapshot) in
            
            var indice = 0
            for requisicao in self.listaRequisicoes {
                if requisicao.key == snapshot.key {
                    self.listaRequisicoes.remove(at: indice)
                }
                indice = indice + 1
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordenadas = manager.location?.coordinate {
            self.localMotorista = coordenadas
        }
        
    }
    
    @IBAction func deslogarMotorista(_ sender: Any) {
        
        let autenticacao = Auth.auth()
        do {
            try autenticacao.signOut()
            dismiss(animated: true, completion: nil)
        } catch  {
            print("Nao foi possível deslogar!")
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = self.listaRequisicoes[ indexPath.row ]
        self.performSegue(withIdentifier: "segueAceitarCorrida", sender: snapshot)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueAceitarCorrida" {
            if let confirmarVC = segue.destination as? ConfirmarRequisicaoViewController {
                
                if let snapshot = sender as? DataSnapshot {
                    if let dados = snapshot.value as? [String: Any] {
                        
                        if let latPassageiro = dados["latitude"] as? Double {
                            if let lonPassageiro = dados["longitude"]  as? Double {
                                if let nomePassageiro = dados["nome"]  as? String {
                                    if let emailPassageiro = dados["email"]  as? String {
                                        
                                        //dados do passageiro
                                        let localPassageiro = CLLocationCoordinate2D(latitude: latPassageiro, longitude: lonPassageiro)
                                        
                                        confirmarVC.nomePassageiro = nomePassageiro
                                        confirmarVC.emailPassageiro = emailPassageiro
                                        confirmarVC.localPassageiro = localPassageiro
                                        
                                        //dados motorista
                                        confirmarVC.localMotorista = self.localMotorista
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.listaRequisicoes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaMotorista", for: indexPath)
        
        let snapshot = self.listaRequisicoes[ indexPath.row ]
        if let dados = snapshot.value as? [String: Any] {
            
            if let latPassageiro = dados["latitude"] as? Double {
                if let lonPassageiro = dados["longitude"] as? Double {
                    
                    let motoristaLocation = CLLocation(latitude: self.localMotorista.latitude, longitude: self.localMotorista.longitude)
                    
                    let passageiroLocation = CLLocation(latitude: latPassageiro, longitude: lonPassageiro)
                    
                    let distanciaMetros = motoristaLocation.distance(from: passageiroLocation)
                    
                    let distanciaKM = distanciaMetros / 1000
                    let distanciaFinal = round( distanciaKM )
                    
                    var requisicaoMotorista = ""
                    if let emailMotoristaR = dados["motoristaEmail"] as? String{
                        let autenticacao = Auth.auth()
                        if let emailMotoristaLogado = autenticacao.currentUser?.email {
                            if emailMotoristaR == emailMotoristaLogado {
                                requisicaoMotorista = " {ANDAMENTO}"
                                if let status = dados["status"] as? String {
                                    if status == StatusCorrida.ViagemFinalizada.rawValue {
                                        requisicaoMotorista = " {FINALIZADA}"
                                    }
                                }
                            }
                        }
                    }
                    
                    if let nomePassageiro = dados["nome"] as? String {
                        celula.textLabel?.text = "\(nomePassageiro) \(requisicaoMotorista)"
                        celula.detailTextLabel?.text = "\(distanciaFinal) KM de distância"
                    }
                    
                    
                }
            }
            
            
            
        }
        
        

        return celula
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
