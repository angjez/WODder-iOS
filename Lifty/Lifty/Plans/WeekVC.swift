//
//  WeekVC.swift
//  Lifty
//
//  Created by Angelika Jeziorska on 05/04/2020.
//  Copyright © 2020 Angelika Jeziorska. All rights reserved.
//

import UIKit
import Eureka

class WeekVC: FormViewController, passPlan, passWeek {
    
    var planDelegate: passPlan?
    var weekDelegate: passWeek?
    var dayDelegate: passDay?
    
    var chosenDay = Day()
    var chosenDayIndex: Int?
    
    var chosenPlan = Plan (name: "")
    var chosenPlanIndex: Int?
    var chosenWeek = Week()
    var chosenWeekIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title =  "Week " + String(self.chosenWeekIndex! + 1)
        
        customiseTableView(tableView: self.tableView, themeColor: UIColor.systemPink)
        
        createTrainingDaysForm()
        createDayRows()
    }
    
    func finishPassing(chosenPlan: Plan, chosenPlanIndex: Int?) {
        self.chosenPlan = chosenPlan
        self.chosenPlanIndex = chosenPlanIndex
    }
    
    func finishPassing(chosenWeek: Week, chosenWeekIndex: Int?) {
        self.chosenWeek = chosenWeek
        self.chosenWeekIndex = chosenWeekIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let tabBarController = self.tabBarController
            else {
                print("Error initializing tab bar controller!")
                return
        }
        guard let navigationController = self.navigationController
            else {
                print("Error initializing navigation controller!")
                return
        }
        
        setPinkGradients(tabBarController: tabBarController, navigationController: navigationController, view: self.view, tableView: self.tableView)
    }
    
    func createTrainingDaysForm () {
        
        let pinkGradientImage = CAGradientLayer.pinkGradient(on: self.view)
        form +++ Section ()
            <<< StepperRow() { row in
                row.tag = "traningDaysStepperRow"
                row.title = "Amount of training days"
                if !self.chosenPlan.weeks[self.chosenWeekIndex!].days.isEmpty {
                    row.value = Cell<Double>.Value(self.chosenPlan.weeks[self.chosenWeekIndex!].days.count)
                }
                else {
                    row.value = 1
                }
                row.displayValueFor = { value in
                    guard let value = value else { return nil }
                    return "\(Int(value))"
                }
            }.cellSetup{ (cell, row) in
                cell.stepper.stepValue = 1
                cell.stepper.maximumValue = 7
                cell.stepper.minimumValue = 1
            }.cellUpdate { (cell, row) in
                self.dayRowsHaveChanged()
                cell.valueLabel.textColor = UIColor.systemPink
                setLabelRowCellProperties(cell: cell, textColor: UIColor.systemPink, borderColor: UIColor(patternImage: pinkGradientImage!))
        }
    }
    
    func dayRowsHaveChanged() {
        let traningDaysStepperRow: StepperRow? = form.rowBy(tag: "traningDaysStepperRow")
        while Int(traningDaysStepperRow!.value!) > self.chosenPlan.weeks[self.chosenWeekIndex!].days.count {
            self.chosenPlan.weeks[self.chosenWeekIndex!].days.append(Day())
            form +++
                ButtonRow () { row in
                    row.title = "Day " + String(self.chosenPlan.weeks[self.chosenWeekIndex!].days.count)
                    row.tag = String(self.chosenPlan.weeks[self.chosenWeekIndex!].days.count - 1)
                    //                    row.presentationMode = .segueName(segueName: "chooseWorkoutSegue", onDismiss: nil)
                    row.onCellSelection(self.assignCellRow)
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.systemPink
                    cell.indentationLevel = 2
                    cell.indentationWidth = 10
                    cell.textLabel!.textAlignment = .left
            }
        }
        while Int(traningDaysStepperRow!.value!) < self.chosenPlan.weeks[self.chosenWeekIndex!].days.count {
            for (index, row) in self.form.rows.enumerated() {
                if row.tag == String(self.chosenPlan.weeks[self.chosenWeekIndex!].days.count - 1) {
                    self.form.remove(at: index)
                }
            }
            self.chosenPlan.weeks[self.chosenWeekIndex!].days.removeLast()
        }
    }
    
    func createDayRows() {
        let traningDaysStepperRow: StepperRow? = form.rowBy(tag: "traningDaysStepperRow")
        while Int(traningDaysStepperRow!.value!) > self.chosenPlan.weeks[self.chosenWeekIndex!].days.count {
            self.chosenPlan.weeks[self.chosenWeekIndex!].days.append(Day())
        }
        for (index, day) in self.chosenPlan.weeks[self.chosenWeekIndex!].days.enumerated() {
            form +++
                ButtonRow () { row in
                    row.title = "Day " + String(index+1)
                    row.tag = String(index)
                    //                    row.presentationMode = .segueName(segueName: "chooseWorkoutSegue", onDismiss: nil)
                    row.onCellSelection(self.assignCellRow)
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.systemPink
                    cell.indentationLevel = 2
                    cell.indentationWidth = 10
                    cell.textLabel!.textAlignment = .left
            }
        }
    }
    
    func assignCellRow(cell: ButtonCellOf<String>, row: ButtonRow) {
        self.chosenDayIndex = Int(row.tag!)
        self.chosenDay = self.chosenPlan.weeks[self.chosenWeekIndex!].days[chosenDayIndex!]
        self.performSegue(withIdentifier: "chooseWorkoutSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc2 = segue.destination as? ChooseWorkoutsVC{
            self.planDelegate = vc2
            self.weekDelegate = vc2
            self.dayDelegate = vc2
            self.planDelegate?.finishPassing(chosenPlan: self.chosenPlan, chosenPlanIndex: self.chosenPlanIndex)
            self.weekDelegate?.finishPassing(chosenWeek: chosenWeek, chosenWeekIndex: chosenWeekIndex)
            self.dayDelegate?.finishPassing(chosenDay: chosenDay, chosenDayIndex: chosenDayIndex)
        }
    }
}
